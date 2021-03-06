//
//  CollectionViewBindingHelper.swift
//  Floh
//
//  Created by Arjun P A on 29/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

@objc protocol ReactiveView {
    func bindViewModel(viewModel: AnyObject)
    func sizeThatFitsPreferredTargetWith(targetSize:CGSize) -> CGSize
}

protocol CollectionViewBindingHelperDelegate:class{
    func paginateInResponseToScroll()
    func didPullToRefresh()
}

class CollectionViewBindingHelper<T:AnyObject>:NSObject{
    
    fileprivate let collection_view:UICollectionView
    fileprivate let sourceSignal:SignalProducer<[T], NoError>
    fileprivate var sizingCell:Dictionary<String, UICollectionViewCell> = [:]
    fileprivate var dataSource:DataSource
    var collectionViewBindingHelperDelegate:CollectionViewBindingHelperDelegate?
    fileprivate var _refreshControl:UIRefreshControl!
    
    init(collectionView:UICollectionView, sourceSignal:SignalProducer<[T], NoError>, nibName:String){
        self.collection_view = collectionView
        self.sourceSignal = sourceSignal
        
        let nib = UINib.init(nibName: nibName, bundle: nil)
        sizingCell[nibName] = nib.instantiate(withOwner: nil, options: nil)[0] as! TweetCell
        collectionView.register(nib, forCellWithReuseIdentifier: nibName)
        dataSource = DataSource.init(data: nil, cell: sizingCell[nibName]!, identifier: nibName)
        
        super.init()
        self.collection_view.dataSource = dataSource
        self.collection_view.delegate = dataSource
        self.addPullToRefresh()
        sourceSignal.startWithResult { [weak self](result) in
            guard let weakSelf = self, let dataNotNil = result.value else{return}
            let newData = dataNotNil.map({$0 as AnyObject})
            weakSelf.dataSource.data = newData
            weakSelf._refreshControl.endRefreshing()
            self?.collection_view.reloadData()
        }
        
        dataSource.completionForScrollPagination = { () in
            self.collectionViewBindingHelperDelegate?.paginateInResponseToScroll()
        }
        
    }
    private func addPullToRefresh(){
        _refreshControl = UIRefreshControl.init()
        self.collection_view.addSubview(_refreshControl)
        _refreshControl.addTarget(self, action: #selector(CollectionViewBindingHelper.pulledToRefresh), for: .valueChanged)
    }
    
    @objc private func pulledToRefresh(){
        self.collectionViewBindingHelperDelegate?.didPullToRefresh()
    }
    
}

class DataSource: NSObject, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    var data:[AnyObject]? = []
    fileprivate var cell:UICollectionViewCell
    fileprivate var identifier:String
    typealias Completion_Block = () -> ()
    var completionForScrollPagination:Completion_Block?
    init(data:[AnyObject]?, cell:UICollectionViewCell, identifier:String) {
        self.data = data
        self.cell = cell
        self.identifier = identifier
        super.init()
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeueCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifier, for: indexPath)
        guard let realCell = dequeueCell as? ReactiveView, let item = data?.safeIndex(i: indexPath.item) else{return UICollectionViewCell()}
        
        realCell.bindViewModel(viewModel: item)
        return dequeueCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sizingCell = cell as? ReactiveView, let item = data?.safeIndex(i: indexPath.item) else {return CGSize.init(width: UIScreen.main.bounds.width, height: 1)}
        sizingCell.bindViewModel(viewModel: item)
        let proposedTargetSize = CGSize.init(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height)
        var fittingSize = sizingCell.sizeThatFitsPreferredTargetWith(targetSize: proposedTargetSize)
        fittingSize.height += 10
        return fittingSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 10, 0, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
extension DataSource:UIScrollViewDelegate{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if distance < 200 {
            completionForScrollPagination?()
        }
    }
}
