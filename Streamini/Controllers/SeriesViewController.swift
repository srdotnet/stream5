//
//  SeriesViewController.swift
//  BEINIT
//
//  Created by Dominic on 2/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeriesViewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet var tableHeader:UIView!
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var topViewTopSpaceConstraint:NSLayoutConstraint!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var pageControl:UIPageControl!
    
    let scrollView=UIScrollView(frame:CGRectMake(0, 0, 320, 300))
    var blockingView:UIView!
    
    override func viewDidLoad()
    {
        scrollView.delegate=self
        tableHeader.addSubview(scrollView)
        
        for index in 0..<2
        {
            let subView=UIView(frame:CGRectMake(CGFloat(index*320), 0, 320, 300))
            scrollView.addSubview(subView)
        }
        
        scrollView.contentSize=CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height)
        
        tableHeader.clipsToBounds=true
        tableView.contentOffset=CGPointMake(0, 64)
        
        blockingView=UIView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
        blockingView.backgroundColor=UIColor.blackColor()
        blockingView.hidden=true
        view!.addSubview(blockingView)
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 80
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 80))
        headerView.backgroundColor=UIColor.blackColor()
        
        let shuffle=UIButton(frame:CGRectMake(40, -25, UIScreen.mainScreen().bounds.size.width-80, 50))
        shuffle.setTitle("SHUFFLE PLAY", forState:.Normal)
        shuffle.backgroundColor=UIColor.greenColor()
        
        let headerTitle=UILabel(frame:CGRectMake(10, 40, UIScreen.mainScreen().bounds.size.width-20, 30))
        headerTitle.text="INCLUDES"
        headerTitle.textColor=UIColor.whiteColor()
        
        headerView.addSubview(shuffle)
        headerView.addSubview(headerTitle)
        
        return headerView
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 10
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        return UITableViewCell()
    }
    
    func scrollViewDidEndDecelerating(scrollView:UIScrollView)
    {
        let pageNumber=scrollView.contentOffset.x/scrollView.frame.size.width
        pageControl.currentPage=Int(pageNumber)
    }
    
    func scrollViewDidScroll(scrollView:UIScrollView)
    {
        if scrollView.contentOffset.y > -20
        {
            if searchBar.alpha==1
            {
                UIView.animateWithDuration(0.3, animations:{()->Void in
                    self.searchBar.alpha=0
                    }, completion:{(finished:Bool)->Void in
                        self.blockingView.hidden=false
                })
            }
            topViewTopSpaceConstraint.constant=max(0, scrollView.contentOffset.y+20)
        }
        else
        {
            if searchBar.alpha==0
            {
                blockingView.hidden=true
                UIView.animateWithDuration(0.3, animations:{()->Void in
                    self.searchBar.alpha=1
                })
            }
            topViewTopSpaceConstraint.constant=0
        }
    }
}
