//
//  DKImageCropperController.swift
//  
//
//  Created by David Ilizarov on 8/28/15.
//
//

import UIKit

class DKImageCropperController: UIViewController {

    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        
        imageView.center = self.view.center
        
        imageView.image = image
        
        self.view.addSubview(imageView)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
