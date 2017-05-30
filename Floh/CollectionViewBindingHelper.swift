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
}

class CollectionViewBindingHelper<T:AnyObject>:NSObject{
    
    fileprivate let collection_view:UICollectionView
    fileprivate let sourceSignal:SignalProducer<[T], NoError>
    fileprivate var sizingCell:Dictionary<String, UICollectionViewCell> = [:]
    fileprivate var dataSource:DataSource
    var collectionViewBindingHelperDelegate:CollectionViewBindingHelperDelegate?

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
        sourceSignal.startWithResult { [weak self](result) in
            guard let weakSelf = self, let dataNotNil = result.value else{return}
            let newData = dataNotNil.map({$0 as AnyObject})
            weakSelf.dataSource.data = newData
            self?.collection_view.reloadData()
        }
        
        dataSource.completionForScrollPagination = { () in
            self.collectionViewBindingHelperDelegate?.paginateInResponseToScroll()
        }
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
        return sizingCell.sizeThatFitsPreferredTargetWith(targetSize: UIScreen.main.bounds.size)
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
