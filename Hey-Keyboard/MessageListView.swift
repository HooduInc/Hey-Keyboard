//
//  MessageListView.swift
//  HeyaKeyboard
//
//  Created by Van Carney on 5/2/15.
//  Copyright (c) 2015 Van Carney. All rights reserved.
//

import UIKit

class MessageListView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var messages = []
    
    
    @IBOutlet var messageList: UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var dict: NSDictionary = self.messages.objectAtIndex(indexPath.row) as! NSDictionary
        
        var cell: MessageCell = NSBundle.mainBundle().loadNibNamed("MessageCell", owner: self, options: nil)[0] as! MessageCell
        
        cell.textLabel?.text    = dict.objectForKey("itemName") as? String
        cell.balloonImage.image = UIImage(named: dict.objectForKey("menuItem") as! String)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
