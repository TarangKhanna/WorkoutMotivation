//
//  postingViewController.swift
//  WorkoutMotivation
//
//  Created by Tarang khanna on 7/2/15.
//  Copyright (c) 2015 Tarang khanna. All rights reserved.
//

import Foundation
import UIKit

class postingViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var commentTxtView: UITextView!
    var text = "What's Up?"
    
    @IBOutlet var postBtn: UIButton!
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    var passedGroup = "general"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.hidden = true
        postBtn.enabled = false
        commentTxtView.text = text
        commentTxtView.textColor = UIColor.lightGrayColor()
        commentTxtView.delegate = self;
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        commentTxtView.text = ""
        
        commentTxtView.textColor = UIColor.blackColor()
        
        
    }
    
    
    @IBAction func post(sender: AnyObject) {
        // send text to timeline controller
        print(self.childViewControllers)
        if commentTxtView.text != " " && commentTxtView.text != nil && !commentTxtView.text.isEmpty {
            let person = PFObject(className:"Person")
            //self.containsImage.append(false)
            //self.parseObject = person
            person["score"] = 0
            person["username"] = PFUser.currentUser()?.username
            person["admin"] = true
            person["text"] = commentTxtView.text
            person["startTime"] = CFAbsoluteTimeGetCurrent()
            person["votedBy"] = []
            person["group"] = passedGroup
            person.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    //self.retrieve()
                    self.performSegueWithIdentifier("backToTimeline", sender: self)
                    //                    let query = PFInstallation.query()
                    //                    if let query = query { // non intrusive
                    //                        //query.whereKey("channels", equalTo: "suitcaseOwners")
                    //                        query.whereKey("deviceType", equalTo: "ios")
                    //                        query.whereKey("")
                    //                        let iOSPush = PFPush()
                    //                        iOSPush.setMessage("General: " + self.commentTxtView.text)
                    //                        //iOSPush.setChannel("suitcaseOwners")
                    //                        iOSPush.setQuery(query)
                    //                        iOSPush.sendPushInBackground()
                    //
                    //                    }
                } else {
                    print("Couldn't post!")
                    SCLAlertView().showWarning("Error Posting", subTitle: "Check Your Internet Connection.")
                }
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        _ = [String]()
        if (segue.identifier == "backToTimeline") { //pass data to VC
            let svc = segue.destinationViewController as! TimelineViewController
            svc.groupToQuery = passedGroup
        } else if (segue.identifier == "backToTimeline2") { //pass data to VC
            let svc = segue.destinationViewController as! TimelineViewController
            svc.groupToQuery = passedGroup
        } else if (segue.identifier == "picUpload") { //pass data to VC
            let svc = (segue.destinationViewController as! UINavigationController).topViewController as! PicUpload
            svc.passedGroupPic = passedGroup
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if commentTxtView.text.length != 0 {
            postBtn.enabled = true
        }
        else if commentTxtView.text.length == 0 {
            postBtn.enabled = false
            commentTxtView.textColor = UIColor.lightGrayColor()
            commentTxtView.text = text
            commentTxtView.resignFirstResponder()
        }
    }
}
