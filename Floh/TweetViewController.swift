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
        self.setupCollectionView()
        collecitonViewBindingHelper = CollectionViewBindingHelper<StatusViewModel>.init(collectionView: self.collection_view, sourceSignal: tweetMentionViewModel.tweets.producer, nibName: "TweetCell")
        collecitonViewBindingHelper.collectionViewBindingHelperDelegate = self
        tweetMentionViewModel.getTweets()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    func setupCollectionView(){
        self.collection_view = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
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
}


