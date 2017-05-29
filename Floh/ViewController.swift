//
//  ViewController.swift
//  Floh
//
//  Created by Arjun P A on 28/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tweetMentionViewModel:TweetMentionViewModel = {
        let bearerModel = TweetMentionViewModel()
        return bearerModel
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetMentionViewModel.getTweets()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

