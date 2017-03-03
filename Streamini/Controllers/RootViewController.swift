//
//  TabBarViewController.swift
//  BEINIT
//
//  Created by Dominic Granito on 29/12/2016.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import Photos

class RootViewController: UIViewController
{
   
}

import MessageUI

//UIViewController
class myProfileViewController: BaseViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, AmazonToolDelegate, UserHeaderViewDelegate, MFMailComposeViewControllerDelegate,
UserSelecting, ProfileDelegate {
    @IBOutlet weak var userHeaderView: UserHeaderView!
  
    var userStatisticsDelegate:UserStatisticsDelegate?
    var userStatusDelegate:UserStatusDelegate?
    
    var user: User?
    var profileDelegate: ProfileDelegate?
    var selectedImage: UIImage?
    
    @IBAction func avatarButtonPressed(sender: AnyObject) {
        let actionSheet = UIActionSheet.changeUserpicActionSheet(self)
        actionSheet.tag = ProfileActionSheetType.ChangeAvatar.rawValue
        actionSheet.showInView(self.view)
    }
    
    
    func userDidSelected(user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
        
        
    }

    
    func logout() {
        let actionSheet = UIActionSheet.confirmLogoutActionSheet(self)
        actionSheet.tag = ProfileActionSheetType.Logout.rawValue
        actionSheet.showInView(self.view)
    }
    
    func configureView()
    {
        self.title = NSLocalizedString("profile_title", comment: "")
        
        userHeaderView.delegate = self
    }
    
    func successGetUser(user: User) {
        self.user = user
        userHeaderView.update(user)
        
       self.navigationItem.rightBarButtonItem = nil
    }
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?)
    {
        if let sid=segue.identifier
        {
            if sid=="UserToLinkedUsers"
            {
                let controller=segue.destinationViewController as! LinkedUsersViewController
                controller.profileDelegate=self
                self.userStatisticsDelegate=controller
            }
        }
    }

    func successFailure(error: NSError) {
        handleError(error)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag == ProfileActionSheetType.ChangeAvatar.rawValue {
            if (buttonIndex == 1) { // Gallery
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
            
            if (buttonIndex == 2) { // Camera
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.Camera
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
        
        if actionSheet.tag == ProfileActionSheetType.Logout.rawValue {
            if buttonIndex != actionSheet.cancelButtonIndex {
                UserConnector().logout(logoutSuccess, failure: logoutFailure)
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
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
        super.viewDidLoad()
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
    
    
    // MARK: - AmazonToolDelegate
    
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
    
    func logoutSuccess()
    {
        if A0SimpleKeychain().stringForKey("PHPSESSID") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("PHPSESSID")
        }
        if A0SimpleKeychain().stringForKey("id") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("id")
        }
        if A0SimpleKeychain().stringForKey("password") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("password")
        }
        if A0SimpleKeychain().stringForKey("secret") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("secret")
        }
        if A0SimpleKeychain().stringForKey("type") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("type")
        }
        
        // deprecated Twitter.sharedInstance().logOut()
        
        /*let store = Twitter.sharedInstance().sessionStore
         
         if let userID = store.session()?.userID {
         store.logOutUserID(userID)
         }*/
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func logoutFailure(error: NSError) {
        print("failure", terminator: "")
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 1 { // following, followers, blocked, streams
            self.performSegueWithIdentifier("ProfileToProfileStatistics", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 { // share
            UINavigationBar.resetCustomAppereance()
            let shareMessage = NSLocalizedString("profile_share_message", comment: "")
            let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1 { // feedback
            UINavigationBar.resetCustomAppereance()
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                let alert = UIAlertView.mailUnavailableErrorAlert()
                alert.show()
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 2 { // Terms Of Service
            self.performSegueWithIdentifier("ProfileToLegal", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 3 { // Privacy Policy
            self.performSegueWithIdentifier("ProfileToLegal", sender: indexPath)
        }
        
        if indexPath.section == 3 && indexPath.row == 0 { // Change Password
            self.performSegueWithIdentifier("ProfileToPassword", sender: indexPath)
        }
        
        if indexPath.section == 3 && indexPath.row == 1 { // logout
            logout()
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
