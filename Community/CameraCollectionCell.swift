//
//  CameraCollectionCell.swift
//  
//
//  Created by David Ilizarov on 8/28/15.
//
//

import UIKit

class CameraCollectionCell: UICollectionViewCell {
 
    var cameraButtonClicked: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let cameraButton = UIButton(frame: frame)
        cameraButton.addTarget(self, action: "takePicture", forControlEvents: .TouchUpInside)
        
        cameraButton.setImage(UIImage(named: "CameraCollection"), forState: .Normal)
        
        cameraButton.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        self.contentView.addSubview(cameraButton)
        
        self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func takePicture() {
        if let cameraButtonClicked = self.cameraButtonClicked {
            self.cameraButtonClicked!()
        }
    }

}
