//
//  CommunityImagePickerViewController.swift
//  
//
//  Created by David Ilizarov on 8/28/15.
//
//

import UIKit

class CommunityImagePickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.registerClass(CameraCollectionCell.self, forCellWithReuseIdentifier: "cameraCollectionIdentifier")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss")
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        // Do any additional setup after loading the view.
    }
    
    func cameraCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cameraCollectionIdentifier", forIndexPath: indexPath) as! CameraCollectionCell
        
        cell.cameraButtonClicked = { [unowned self] () in
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            let pickerController = UIImagePickerController()
                pickerController.sourceType = .Camera
                pickerController.allowsEditing = false
                pickerController.delegate = self
            
                self.presentViewController(pickerController, animated: true, completion: nil)
            
            }
        }
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        return self.cameraCellForIndexPath(indexPath)
//        if (indexPath.row == 0) {
//            return self.cameraCellForIndexPath(indexPath)
//        } else {
//            return self.imageCellForIndexPath(indexPath)
//        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
