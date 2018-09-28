//
//  UserCollectionViewCell.swift
//  Eri Dating
//
//  Created by Dayan Yonnatan on 28/11/2016.
//  Copyright © 2016 Dayan Yonnatan. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell, ConnectedImageDelegate {
    
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var onlineStatusImageView: UIImageView! {
        didSet {
            onlineStatusImageView.layer.cornerRadius = 7
            onlineStatusImageView.layer.masksToBounds = true
            onlineStatusImageView.contentMode = .scaleAspectFill
        }
    }
    
    func updateWithStatus(connectionStatus:ConnectionStatus) {
        if connectionStatus == .Offline {
            self.onlineStatusImageView.image = nil
        } else if connectionStatus == .Online {
            self.onlineStatusImageView.image = UIImage(named: "green")
        }
    }

    var user:EDUser! {
        didSet {
            if let uid = user.id {
                self.userConnectionImage = ConnectedImage(userUID:uid)
            }
        }
    }
    
    var userConnectionImage:ConnectedImage?
    
    override func prepareForReuse() {
        self.userImage.image = nil
        self.onlineStatusImageView.image = nil
        
        super.prepareForReuse()
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)

		
    }
	func setupConstraint(collectionViewWidth: CGFloat) {
		self.widthAnchor.constraint(equalToConstant: collectionViewWidth/3).isActive = true
	}
    
    
}
