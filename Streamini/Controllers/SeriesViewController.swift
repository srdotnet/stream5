//
//  SeriesViewController.swift
//  BEINIT
//
//  Created by Dominic on 2/15/17.
//  Copyright © 2017 Cedricm Video. All rights reserved.
//

class SeriesViewController: UIViewController
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var pageControl:UIPageControl!
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var searchView:UIView!
    @IBOutlet var cancelButton:UIButton!
    @IBOutlet var filterButton:UIButton!
    @IBOutlet var topViewTopSpaceConstraint:NSLayoutConstraint!
    
    var blockingView:UIView!
    
    override func viewDidLoad()
    {
        scrollView.contentSize=CGSizeMake(view.frame.size.width*2, 276)
        
        let playlistView=PlaylistView.instanceFromNib()
        playlistView.frame=CGRectMake(0, 0, view.frame.size.width, 276)
        scrollView.addSubview(playlistView)
        
        let playlistDetailView=PlaylistDetailView.instanceFromNib()
        playlistDetailView.frame=CGRectMake(view.frame.size.width, 0, view.frame.size.width, 276)
        scrollView.addSubview(playlistDetailView)
        
        navigationController!.navigationBar.backgroundColor=UIColor.clearColor()
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics:.Default)
        
        tableView.contentOffset=CGPointMake(0, 64)
        
        blockingView=UIView(frame:CGRectMake(0, 0, view.frame.size.width, 64))
        blockingView.backgroundColor=UIColor.blackColor()
        view.addSubview(blockingView)
    }
    
    func tableView(tableView:UITableView, heightForHeaderInSection section:Int)->CGFloat
    {
        return 80
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, view.frame.size.width, 80))
        headerView.backgroundColor=UIColor.darkGrayColor()
        
        let shuffle=UIButton(frame:CGRectMake(40, 0, view.frame.size.width-80, 50))
        shuffle.setTitle("SHUFFLE PLAY", forState:.Normal)
        shuffle.backgroundColor=UIColor.greenColor()
        
        let headerTitle=UILabel(frame:CGRectMake(10, 55, view.frame.size.width-20, 20))
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
        let pageNumber=self.scrollView.contentOffset.x/scrollView.frame.size.width
        pageControl.currentPage=Int(pageNumber)
    }
    
    func scrollViewDidScroll(scrollView:UIScrollView)
    {
        if scrollView==tableView
        {
            if scrollView.contentOffset.y > -20
            {
                if searchView.alpha==1
                {
                    UIView.animateWithDuration(0.3, animations:{()->Void in
                        self.searchView.alpha=0
                        }, completion:{(finished:Bool)->Void in
                            self.blockingView.hidden=false
                    })
                }
                
                topViewTopSpaceConstraint.constant=max(0, scrollView.contentOffset.y+20)
            }
            else
            {
                if searchView.alpha==0
                {
                    blockingView.hidden=true
                    UIView.animateWithDuration(0.3, animations:{()->Void in
                        self.searchView.alpha=1
                    })
                }
                
                topViewTopSpaceConstraint.constant=0
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar:UISearchBar)
    {
        searchBar.resignFirstResponder()
        filterButton?.hidden=false
        cancelButton?.hidden=true
    }
    
    func searchBarTextDidBeginEditing(searchBar:UISearchBar)
    {
        filterButton?.hidden=true
        cancelButton?.hidden=false
    }
    
    func searchBar(searchBar:UISearchBar, textDidChange searchText:String)
    {
        if searchText.characters.count>0
        {
            
        }
    }
        
    @IBAction func cancel()
    {
        searchBar.resignFirstResponder()
        filterButton?.hidden=false
        cancelButton?.hidden=true
    }
}
