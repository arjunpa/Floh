//
//  ViewController.swift
//  Floh
//
//  Created by Arjun P A on 28/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import UIKit
import ReactiveSwift

class TweetViewController: UIViewController {
    
    var tweetMentionViewModel:TweetMentionViewModel = {
        let bearerModel = TweetMentionViewModel()
        return bearerModel
    }()
    var collection_view:UICollectionView!
    var collecitonViewBindingHelper:CollectionViewBindingHelper<StatusViewModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupCollectionView()
        collecitonViewBindingHelper = CollectionViewBindingHelper<StatusViewModel>.init(collectionView: self.collection_view, sourceSignal: tweetMentionViewModel.tweets.producer, nibName: "TweetCell")
        collecitonViewBindingHelper.collectionViewBindingHelperDelegate = self
        tweetMentionViewModel.getTweets()
        showOrHideLoader()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func showOrHideLoader(){
        tweetMentionViewModel.isSearching.producer.startWithResult { [weak self](result) in
            guard let weakSelf = self else{return}
            if result.value!{
                weakSelf.setupLoadingItem()
            }
            else{
                weakSelf.removeLoadingItem()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func setupLoadingItem(){
        
        let loadingItem = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        loadingItem.hidesWhenStopped = true
        loadingItem.startAnimating()
        loadingItem.color = UIColor.darkGray
        let rightBarItem = UIBarButtonItem.init(customView: loadingItem)
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    func removeLoadingItem(){
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func setupCollectionView(){
        let customLayout = IGListCollectionViewLayout.init(stickyHeaders: false, topContentInset: 0, stretchToEdge: true)
        self.collection_view = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: customLayout)
        self.collection_view.backgroundColor = UIColor.lightGray
        self.collection_view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collection_view)
        self.collection_view.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        self.collection_view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.collection_view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.collection_view.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: 0).isActive = true
    }
    
    
}
extension TweetViewController:CollectionViewBindingHelperDelegate{
    func paginateInResponseToScroll() {
        tweetMentionViewModel.getTweets()
    }
    
    func didPullToRefresh() {
        tweetMentionViewModel.reset()
        tweetMentionViewModel.getTweets()
    }
}


