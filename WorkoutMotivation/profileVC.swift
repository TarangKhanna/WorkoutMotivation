//
//  profileVC.swift
//  WorkoutMotivation
//
//  Created by Tarang khanna on 5/29/15.
//  Copyright (c) 2015 Tarang khanna. All rights reserved.
//


import UIKit

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

class profileVC: UIViewController, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate,  UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    
    @IBOutlet var profileName: UILabel!
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var avatarImage:UIImageView!
    @IBOutlet var header:UIView!
    @IBOutlet var headerLabel:UILabel!
    @IBOutlet var headerImageView:UIImageView!
    @IBOutlet var headerBlurImageView:UIImageView!
    @IBOutlet var scoreLabel: UILabel!
    
    @IBOutlet var aboutYouLabel: UILabel!
    var name : String = ""
    var aboutYou : String = ""
    var score: String = ""
    var profileImageFile = PFFile()
    var blurredHeaderImageView:UIImageView?
    var liked = false
    //var profileObject = PFObject()
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    var show = false
    var canChange = false
    
    override func viewWillAppear(animated: Bool) {
        let show2 = show
        if show2 {
            if self.revealViewController() != nil {
                menuBarButton.target = self.revealViewController()
                menuBarButton.action = "revealToggle:"
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
        } else {
            menuBarButton = nil
        }
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.layer.borderColor = UIColor.redColor().CGColor
        aboutYouLabel.text = ""
        scoreLabel.text = score
        var name2 = name
        name2.replaceRange(name.startIndex...name.startIndex, with: String(name[name.startIndex]).capitalizedString)
        profileName.text = name2
        let queryUser = PFUser.query() as PFQuery?
        queryUser!.findObjectsInBackgroundWithBlock {
            (users: [AnyObject]?, error: NSError?) -> Void in
            //queryUser!.orderByDescending("createdAt")
            //queryUser!.whereKey("username", equalTo: self.name)
            if error == nil {
                //println("Successfully retrieved \(users!.count) users.")
                // Do something with the found users
                if let users = users as? [PFObject] {
                    for user in users {
                        let user2:PFUser = user as! PFUser
                        if user2.username == self.name {
                            self.aboutYouLabel.text = user2["AboutYou"] as? String
                            print("wfkjbf")
                            print((user2["AboutYou"] as? String)!)
                            self.profileImageFile = user2["ProfilePicture"] as! PFFile
                            self.profileImageFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                                
                                if let downloadedImage = UIImage(data: data!) {
                                    self.avatarImage.image = downloadedImage
                                }
                                
                            }
                            //self.imageFiles.append(user2["ProfilePictue"] as! PFFile)
                        }
                        //self.tableView.reloadData()
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        let changeProfilePicGesture =
        UITapGestureRecognizer(target: self, action: "changePic:")
        self.avatarImage.addGestureRecognizer(changeProfilePicGesture)
        if PFUser.currentUser()?.username == name {
            let likeProfileGesture = UILongPressGestureRecognizer(target: self, action: "longPressed:")
            self.avatarImage.addGestureRecognizer(likeProfileGesture)
        }
    }
    
    
    func changePic(sender: UILongPressGestureRecognizer) // liked profile
    {
        
        //        var user = PFUser.currentUser()
        //        var relation = user!.relationForKey("likes")
        //        relation.addObject(post)
        //        user.saveInBackgroundWithBlock {
        //            (success: Bool, error: NSError?) -> Void in
        //            if (success) {
        //                // The post has been added to the user's likes relation.
        //            } else {
        //                // There was a problem, check error.description
        //            }
        //        }
        if (sender.state == UIGestureRecognizerState.Ended) {
            //Do Whatever You want on End of Gesture
            // change profile pic
            print(name)
            
            
            let alert = SCLAlertView()
            alert.addButton("Choose From Gallery") {
                let image = UIImagePickerController()
                image.delegate = self
                image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                image.allowsEditing = false
                self.presentViewController(image, animated: true, completion: nil)
            }
            alert.addButton("Take Photo") {
                imagePicker =  UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
            alert.showEdit("Change", subTitle:"Change Profile Picture:", closeButtonTitle: "Cancel")
            
        }
        else if (sender.state == UIGestureRecognizerState.Began){
            //Do Whatever You want on Began of Gesture
            
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let currentUser = PFUser.currentUser()
        self.dismissViewControllerAnimated(true, completion:nil)
        
        if let imageData = image!.mediumQualityJPEGNSData as NSData? { // choose low to reduce by 1/8
            
            var imageSize = Float(imageData.length)
            
            imageSize = imageSize/(1024*1024) // in Mb
            
            print("Image size is \(imageSize)Mb")
            
            if imageSize < 5 {
                
                if let imageFile = PFFile(name: "image.png", data: imageData) as PFFile? {
                    currentUser!.setObject(imageFile, forKey: "ProfilePicture")
                    currentUser?.saveInBackground()
                }
            }
        }
    }
    
    
    
    
    
    func longPressed(sender: UILongPressGestureRecognizer) // liked profile
    {
        
        //        var user = PFUser.currentUser()
        //        var relation = user!.relationForKey("likes")
        //        relation.addObject(post)
        //        user.saveInBackgroundWithBlock {
        //            (success: Bool, error: NSError?) -> Void in
        //            if (success) {
        //                // The post has been added to the user's likes relation.
        //            } else {
        //                // There was a problem, check error.description
        //            }
        //        }
        if (sender.state == UIGestureRecognizerState.Ended) {
            //Do Whatever You want on End of Gesture
        }
        else if (sender.state == UIGestureRecognizerState.Began){
            //Do Whatever You want on Began of Gesture
            if !liked { // if currrent user likes the passed name user object?
                avatarImage.layer.borderColor = UIColor.whiteColor().CGColor
                liked = true
            } else {
                avatarImage.layer.borderColor = UIColor.redColor().CGColor
                liked = false
            }
        }
        
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "zoomIn") { //pass data to VC
            let svc = segue.destinationViewController as! LayoutController;
            svc.name2 = name
            //NSThread.sleepForTimeInterval(10)
            
            //get profile pic
            let queryUser = PFUser.query() as PFQuery?
            queryUser!.findObjectsInBackgroundWithBlock {
                (users: [AnyObject]?, error: NSError?) -> Void in
                queryUser!.orderByDescending("createdAt")
                queryUser!.whereKey("username", equalTo: self.name)
                if error == nil {
                    //println("Successfully retrieved \(users!.count) users.")
                    // Do something with the found users
                    if let users = users as? [PFObject] {
                        for user in users {
                            let user2:PFUser = user as! PFUser
                            if user2.username == self.name {
                                self.profileImageFile = user2["ProfilePicture"] as! PFFile
                                self.profileImageFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                                    
                                    if let downloadedImage = UIImage(data: data!) {
                                        
                                        svc.downloadedImage2 = downloadedImage
                                        
                                    }
                                    
                                }
                                //self.imageFiles.append(user2["ProfilePictue"] as! PFFile)
                                
                            }
                        }
                        //self.tableView.reloadData()
                    }
                    
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Header - Image
        
        headerImageView = UIImageView(frame: header.bounds)
        headerImageView?.image = UIImage(named: "header_bg")
        headerImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        header.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        
        headerBlurImageView = UIImageView(frame: header.bounds)
        headerBlurImageView?.image = UIImage(named: "header_bg")?.blurredImageWithRadius(10, iterations: 20, tintColor: UIColor.clearColor())
        headerBlurImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        headerBlurImageView?.alpha = 0.0
        header.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        header.clipsToBounds = true
        
        headerLabel.text = "You Broke it"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //        var offset = scrollView.contentOffset.y
        //        var avatarTransform = CATransform3DIdentity
        //        var headerTransform = CATransform3DIdentity
        //
        //        // PULL DOWN -----------------
        //
        //        if offset < 0 {
        //
        //            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
        //            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
        //            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
        //            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
        //
        //            header.layer.transform = headerTransform
        //        }
        //
        //            // SCROLL UP/DOWN ------------
        //
        //        else {
        //
        //            // Header -----------
        //
        //            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
        //
        //            //  ------------ Label
        //
        //            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
        //            headerLabel.layer.transform = labelTransform
        //
        //            //  ------------ Blur
        //
        //            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
        //
        //            // Avatar -----------
        //
        //            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
        //            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
        //            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
        //            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
        //
        //            if offset <= offset_HeaderStop {
        //
        //                if avatarImage.layer.zPosition < header.layer.zPosition{
        //                    header.layer.zPosition = 0
        //                }
        //
        //            }else {
        //                if avatarImage.layer.zPosition >= header.layer.zPosition{
        //                    header.layer.zPosition = 2
        //                }
        //            }
        //        }
        //
        //        // Apply Transformations
        //
        //        header.layer.transform = headerTransform
        //        avatarImage.layer.transform = avatarTransform
    }
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        // This *forces* a popover to be displayed on the iPhone
        return .None
    }
    
    
    // friends feature - >> friendsRelation.addObject(object);
    
    //    @IBAction func addFriend(sender : AnyObject) {
    //
    //        var currentUser = PFUser.currentUser()
    //
    //        var alert = UIAlertController(title: "Add Friend", message: "Pleae enter a username.", preferredStyle: UIAlertControllerStyle.Alert)
    //        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
    //            textField.placeholder = "Username"
    //            textField.secureTextEntry = false
    //
    //            // Add button actions here
    //            var addBtnAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) {
    //                UIAlertAction in
    //
    //                var text : String = textField.text
    //
    //                println("I want to add the user: \(text)")
    //
    //                var query = PFUser.query()
    //                query.whereKey("username", equalTo: text)
    //                query.getFirstObjectInBackgroundWithBlock {
    //                    (object: PFObject!, error: NSError!) -> Void in
    //                    if !object {
    //                        NSLog("The getFirstObject request failed.")
    //                        //add alertView here later
    //
    //                    } else {
    //                        // The find succeeded.
    //                        NSLog("Successfully retrieved the object.")
    //                        //This can find username successfully
    //
    //                        var friendsRelation : PFRelation = currentUser.relationForKey("friendsRelation")
    //                        var user : PFUser = text
    //                        // Xcode tells me that I cannot express a String as a PFUser
    //                        // How can I add the user that has the exact same username?
    //
    //                    }
    //                }
    //            }
    //
    //            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
    //            alert.addAction(addBtnAction)
    //            self.presentViewController(alert, animated: true, completion: nil)
    //
    //        })
    //    }
    
}