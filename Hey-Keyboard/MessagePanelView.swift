//
//  MessagePanelView.swift
//  HeyaKeyboard
//
//  Created by Van Carney on 5/2/15.
//  Copyright (c) 2015 Van Carney. All rights reserved.
//

import UIKit

class MessagePanelView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var messageList: UITableView!
    
    var keyboardDelegate: KeyboardDelegate!
    
    var messages: NSMutableArray = []
//        {
//        willSet(newItems){
//            
//        }
//        didSet(newItems){
//            
//        }
//    }
    
    
    @IBOutlet weak var table: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initViewFromNib()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initViewFromNib()
    }
    
    func getOrientation() -> String {
        var orientation: String = "Portrait"
        
        if(UIScreen.mainScreen().bounds.size.width > UIScreen.mainScreen().bounds.size.height){
            orientation = "Landscape"
        }
        
        return orientation
    }
    
    private func initViewFromNib() {
        let view = NSBundle.mainBundle().loadNibNamed("MessageListView", owner: self, options: nil)[0] as! UITableView
        view.setTranslatesAutoresizingMaskIntoConstraints(false)

        self.addSubview(view)
        
        var leftSideConstraint = NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0.0)
        var bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        var widthConstraint = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
        
//        var hConstant : CGFloat = 0.0
//        if self.frame.size.height > self.superview!.bounds.height {
//            hConstant = self.superview!.bounds.height - self.frame.size.height
//        }
        
        var heightConstraint = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1.0, constant: 0.0)
        
        self.addConstraints([leftSideConstraint, bottomConstraint, heightConstraint, widthConstraint])
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getOrientation() == "Portrait" {
            self.messageList.rowHeight = ceil(self.messageList.frame.size.height / CGFloat(self.messages.count)) //- 20
        }
        else {
            self.messageList.rowHeight = 44.0
        }
        return self.messages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var dict: NSDictionary = self.messages.objectAtIndex(indexPath.row) as! NSDictionary;
        
        var cell: MessageCell = NSBundle.mainBundle().loadNibNamed("MessageCell", owner: self, options: nil)[0] as! MessageCell;
        
        var bounds:CGRect = cell.bounds;
        
        cell.textLabel?.font  = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline);
        cell.indentationLevel = 1;
        cell.indentationWidth = 16;
        cell.textLabel?.textColor = UIColor.whiteColor();
        cell.textLabel?.text    = dict.objectForKey("MenuName") as? String;
        cell.balloonImage.image = UIImage(named: dict.objectForKey("MenuColor") as! String);

        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
        var tappedItem: NSDictionary = self.messages.objectAtIndex(indexPath.row) as! NSDictionary
        var message: String = tappedItem.objectForKey("MenuName") as! String;
        keyboardDelegate.insertText(message);
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */

}
