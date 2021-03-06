//
//  VideosViewController.swift
//  BEINIT
//
//  Created by Ankit Garg on 3/9/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class VideosViewController: UIViewController
{
    var vType:Int!
    var TBVC:TabBarViewController!
    var favouriteStreams:[NSManagedObject]?
    let (host, _, _, _, _)=Config.shared.wowza()
    
    override func viewDidLoad()
    {
        TBVC=tabBarController as! TabBarViewController
        
        favouriteStreams=SongManager.getFavourites(vType)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return favouriteStreams!.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("RecentStreamCell") as! RecentStreamCell
        
        cell.streamNameLabel?.text=favouriteStreams![indexPath.row].valueForKey("streamTitle") as? String
        cell.userLabel?.text=favouriteStreams![indexPath.row].valueForKey("streamUserName") as? String
        cell.playImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(favouriteStreams![indexPath.row].valueForKey("streamID") as! Int).jpg"))
        
        cell.dotsButton?.tag=indexPath.row
        cell.dotsButton?.addTarget(self, action:#selector(dotsButtonTapped), forControlEvents:.TouchUpInside)
        
        return cell
    }
    
    func dotsButtonTapped(sender:UIButton)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("PopUpViewController") as! PopUpViewController
        vc.stream=makeStreamClassObject(sender.tag)
        presentViewController(vc, animated:true, completion:nil)
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
        
        let streamsArray=NSMutableArray()
        streamsArray.addObject(makeStreamClassObject(indexPath.row))
        
        modalVC.streamsArray=streamsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(makeStreamClassObject(indexPath.row))
    }
    
    func makeStreamClassObject(row:Int)->Stream
    {
        let user=User()
        
        user.name=favouriteStreams![row].valueForKey("streamUserName") as! String
        user.id=favouriteStreams![row].valueForKey("streamUserID") as! UInt
        
        let stream=Stream()
        
        stream.id=favouriteStreams![row].valueForKey("streamID") as! UInt
        stream.title=favouriteStreams![row].valueForKey("streamTitle") as! String
        stream.streamHash=favouriteStreams![row].valueForKey("streamHash") as! String
        stream.videoID=favouriteStreams![row].valueForKey("streamKey") as! String
        stream.user=user
        
        return stream
    }
}
