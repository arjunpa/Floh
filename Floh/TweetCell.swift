//
//  TweetCell.swift
//  Floh
//
//  Created by Arjun P A on 30/05/17.
//  Copyright © 2017 Arjun P A. All rights reserved.
//

import UIKit
import ReactiveSwift
import AlamofireImage

class TweetCell: UICollectionViewCell, ReactiveView {

    @IBOutlet weak var avatarImageView:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var tweetText:UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization codex
        tweetText.textContainerInset = UIEdgeInsets.zero
    }
    
    func bindViewModel(viewModel: AnyObject){
        if let tweetVM = viewModel as? StatusViewModel{
            tweetText.text = tweetVM.tweetText
            name.text = tweetVM.userName
            if let imageURL = URL.init(string: tweetVM.avatarURL){
                avatarImageView.af_setImage(withURL: imageURL)
            }
        }
    }
    
    func sizeThatFitsPreferredTargetWith(targetSize:CGSize) -> CGSize{
        var changeSize = targetSize
        changeSize.width = targetSize.width
        let widthConstraint = NSLayoutConstraint(item: self.contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant:changeSize.width)
        widthConstraint.priority = 998
        contentView.addConstraint(widthConstraint)
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        var size = UILayoutFittingCompressedSize
        size.width = changeSize.width
        let someSize = self.contentView.systemLayoutSizeFitting(size, withHorizontalFittingPriority: 1000, verticalFittingPriority: 250)
        
        contentView.removeConstraint(widthConstraint)
        
        return someSize
    }

}
