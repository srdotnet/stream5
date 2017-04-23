//
//  ProfileViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import MessageUI

enum ProfileActionSheetType:Int
{
    case ChangeAvatar
    case Logout
}

protocol ProfileDelegate:class
{
    func reload()
    func close()
}

class ProfileViewController: BaseTableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, AmazonToolDelegate, UserHeaderViewDelegate, MFMailComposeViewControllerDelegate,
ProfileDelegate
{
    @IBOutlet var userHeaderView: UserHeaderView!
    @IBOutlet var followingValueLabel: UILabel!
    @IBOutlet var followersValueLabel: UILabel!
    @IBOutlet var blockedValueLabel: UILabel!
    @IBOutlet var streamsValueLabel: UILabel!
    
    var user: User?
    var profileDelegate: ProfileDelegate?
    var selectedImage: UIImage?
    
    @IBAction func avatarButtonPressed(sender: AnyObject) {
        let actionSheet = UIActionSheet.changeUserpicActionSheet(self)
        actionSheet.tag = ProfileActionSheetType.ChangeAvatar.rawValue
        actionSheet.showInView(self.view)
    }
    
    func configureView()
    {
        userHeaderView.delegate = self
    }
    
    func successGetUser(user: User)
    {
        self.user = user
        userHeaderView.update(user)
        
        followingValueLabel.text    = "\(user.following)"
        followersValueLabel.text    = "\(user.followers)"
        blockedValueLabel.text      = "\(user.blocked)"
        streamsValueLabel.text      = "\(user.streams)"
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func successFailure(error: NSError) {
        handleError(error)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag == ProfileActionSheetType.ChangeAvatar.rawValue {
            if (buttonIndex == 1) { 
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
            
            if (buttonIndex == 2) {
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.Camera
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.selectedImage = image.fixOrientation().imageScaledToFitToSize(CGSizeMake(100, 100))
            self.uploadImage(self.selectedImage!)
        })
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
       
        
        navigationController.navigationBar.tintColor = UIColor.blueColor()
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blueColor()]
        
       // navigationController.navigationBar.tintColor = UIColor.whiteColor()
       // navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    func uploadImage(image: UIImage) {
        let filename = "\(UserContainer.shared.logged().id)-avatar.jpg"
                        
        if AmazonTool.isAmazonSupported() {
            AmazonTool.shared.uploadImage(image, name: filename) { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    let progress: Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    self.userHeaderView.progressView.setProgress(progress, animated: true)
                })
            }
        } else {
            let data = UIImageJPEGRepresentation(image, 1.0)!
            UserConnector().uploadAvatar(filename, data: data, success: uploadAvatarSuccess, failure: uploadAvatarFailure, progress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                    let progress: Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    self.userHeaderView.progressView.setProgress(progress, animated: true)
            })
        }
    }
    
    override func viewDidLoad()
    {
        self.configureView()
        
        let activator=UIActivityIndicatorView(activityIndicatorStyle:.White)
        activator.startAnimating()
        
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView:activator)
        UserConnector().get(nil, success:successGetUser, failure:successFailure)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        super.viewWillAppear(animated)
        AmazonTool.shared.delegate = self
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UINavigationBar.setCustomAppereance()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        AmazonTool.shared.delegate = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let sid = segue.identifier
        {
            if sid == "ProfileToProfileStatistics"
            {
                let controller = segue.destinationViewController as! ProfileStatisticsViewController
                let index = (sender as! NSIndexPath).row
                controller.type = ProfileStatisticsType(rawValue: index)!
                controller.profileDelegate = self
            }
        }
    }
    
    func uploadAvatarSuccess() {
        userHeaderView.progressView.setProgress(0.0, animated: false)
        userHeaderView.updateAvatar(user!, placeholder: selectedImage!)
        if let delegate = profileDelegate {
            delegate.reload()
        }
    }
    
    func uploadAvatarFailure(error: NSError) {
        handleError(error)
    }
    
    func imageDidUpload() {
        UserConnector().avatar(uploadAvatarSuccess, failure: uploadAvatarFailure)
    }
    
    func imageUploadFailed(error: NSError) {
        handleError(error)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 1
        {
            self.performSegueWithIdentifier("ProfileToProfileStatistics", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 0
        {
            UINavigationBar.resetCustomAppereance()
            let shareMessage = NSLocalizedString("profile_share_message", comment: "")
            let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1
        {
            UINavigationBar.resetCustomAppereance()
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                let alert = UIAlertView.mailUnavailableErrorAlert()
                alert.show()
            }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Config.shared.feedback()])
        mailComposerVC.setSubject(NSLocalizedString("feedback_title", comment: ""))
        
        let appVersion  = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let appBuild    = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        let deviceName  = UIDevice.currentDevice().name
        let iosVersion  = "\(UIDevice.currentDevice().systemName) \(UIDevice.currentDevice().systemVersion)"
        let userId      = user!.id
        
        var message = "\n\n\n"
        message = message.stringByAppendingString("App Version: \(appVersion)\n")
        message = message.stringByAppendingString("App Build: \(appBuild)\n")
        message = message.stringByAppendingString("Device Name: \(deviceName)\n")
        message = message.stringByAppendingString("iOS Version: \(iosVersion)\n")
        message = message.stringByAppendingString("User Id: \(userId)")
        
        mailComposerVC.setMessageBody(message, isHTML: false)
        
        mailComposerVC.delegate = self
        
        return mailComposerVC
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        //controller.dismissViewControllerAnimated(true, completion: nil)
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
           // if result.rawValue == MFMailComposeResultFailed.rawValue {
             //   let alert = UIAlertView.sendMailErrorAlert()
               // alert.show()
            //}
        })
    }
    
    // MARK: - ProfileDelegate
    
    func reload() {
        UserConnector().get(nil, success: successGetUser, failure: successFailure)
    }
    
    func close() {
    }
    
    // MARK: - UserHeaderViewDelegate
    
    func usernameLabelPressed()
    {
        
    }
    
    func descriptionWillStartEdit()
    {
        let doneBarButtonItem=UIBarButtonItem(barButtonSystemItem:.Done, target:self, action:#selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem=doneBarButtonItem
    }
    
    func doneButtonPressed(sender: AnyObject) {
        let text: String
        if userHeaderView.userDescriptionTextView.text == NSLocalizedString("profile_description_placeholder", comment: "") {
            text = " "
        } else {
            text = userHeaderView.userDescriptionTextView.text
        }
        
        let activator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activator)
        
        UserConnector().userDescription(text, success: userDescriptionTextSuccess, failure: userDescriptionTextFailure)
    }
    
    func userDescriptionTextSuccess() {
        self.navigationItem.rightBarButtonItem = nil
        userHeaderView.userDescriptionTextView.resignFirstResponder()
        
        if let delegate = profileDelegate {
            delegate.reload()
        }
    }
    
    func userDescriptionTextFailure(error:NSError)
    {
        handleError(error)
        let doneBarButtonItem=UIBarButtonItem(barButtonSystemItem:.Done, target:self, action:#selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem=doneBarButtonItem
    }
}
