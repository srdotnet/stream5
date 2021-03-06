//
//  CategoryRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoryRow: UITableViewCell
{
    @IBOutlet var collectionView:UICollectionView?
    var oneCategoryItemsArray:NSArray!
    var TBVC:TabBarViewController!
    let (host, _, _, _, _)=Config.shared.wowza()
    var cellIdentifier:String?
    
    func reloadCollectionView()
    {
        collectionView!.reloadData()
    }
    
    func collectionView(collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return oneCategoryItemsArray.count
    }
    
    func collectionView(collectionView:UICollectionView, cellForItemAtIndexPath indexPath:NSIndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier!, forIndexPath:indexPath) as! VideoCell
        
        let stream=oneCategoryItemsArray[indexPath.row] as! Stream
        
        cell.videoTitleLbl?.text=stream.title
        
        if cellIdentifier=="videoCell"
        {
            cell.followersCountLbl?.text=stream.user.name
            cell.videoThumbnailImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(stream.id).jpg"))
            
            let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
            cell.tag=indexPath.row
            cell.addGestureRecognizer(cellRecognizer)
        }
        else
        {
            if indexPath.row==0
            {
                cell.videoTitleLbl?.hidden=true
                cell.followersCountLbl?.hidden=true
                cell.videoThumbnailImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumb/\(stream.id).jpg"))
            }
            else
            {
                cell.backgroundColor=UIColor.clearColor()
                cell.followersCountLbl?.text=stream.user.name
            }
        }
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
        
        let stream=oneCategoryItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        let streamsArray=NSMutableArray()
        streamsArray.addObject(stream)
        
        modalVC.streamsArray=streamsArray
        modalVC.TBVC=TBVC
        
        TBVC.modalVC=modalVC
        TBVC.configure(stream)
    }
    
    func collectionView(collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath)->CGSize
    {
        let width=(collectionView.frame.size.width-25)/2
        
        if cellIdentifier=="weeklyCell"
        {
            return CGSizeMake(width, width)
        }
        else
        {
            return CGSizeMake(width, width+65)
        }
    }
}
