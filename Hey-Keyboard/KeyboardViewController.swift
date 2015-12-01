//
//  KeyboardViewController.swift
//  Hey Keyboard
//
//  Created by Van Carney on 4/28/15.
//  Copyright (c) 2015 Van Carney. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController, UIScrollViewDelegate {

    @IBOutlet weak var nextKeyboard: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var pager: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var navView: UIView!
    
    var perPage: Int = 8
    
    var pages: [MessagePanelView?] = []
    
    var messages: NSMutableArray = []
    
    var _initialized: Bool = false
    
    var _originFrame: CGRect!
    
    
    

    func scrollViewDidScroll(scrollView:UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let _page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pager.currentPage = _page
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.scrollView.sizeToFit()
        
        // Add custom view sizing constraints here
    }

    @IBAction func unwindToKeyboard(segue: UIStoryboardSegue) {
        
    }

    @IBAction func pageChange(currentPage:Int) {
        var _x: CGFloat = CGFloat(  Int(scrollView.frame.size.width) * pager.currentPage )
        scrollView.setContentOffset(CGPoint(x: _x, y: 0.0), animated: true)
    }
    
    func initializeData() {
        let appGroupName = "group.V832NBX5Y5.com.hooduinc.HeyKeyboard";
        let fm = NSFileManager.defaultManager();
        var containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupName)!;
        self.messages = DBManager.fetchmenu(0, noOfRows:32);
    }
    
    func setupSize() {
        var oriented: String = self.getOrientation()
        var screen: UIScreen = UIScreen.mainScreen()
        self.viewHeight.constant = screen.bounds.size.height
    }
    
    func getOrientation() -> String {
        var orientation: String = "Portrait"
        
        if(UIScreen.mainScreen().bounds.size.width > UIScreen.mainScreen().bounds.size.height){
            orientation = "Landscape"
        }
        
        return orientation
    }
    
    func getPanelBounds() -> CGRect {
        return self.view.bounds
    }
    
    func createPanel(index: Int, frame: CGRect) -> MessagePanelView {
        let oriented = self.getOrientation()
        let keyboardDelegate = KeyboardDelegate(parent:self)
        
        var page: MessagePanelView = MessagePanelView(frame: frame )
        page.table.contentMode = .ScaleAspectFill
        page.keyboardDelegate = keyboardDelegate

        return page
    }
    
    func assignMessagesToPage(page: MessagePanelView, offset: Int, count: Int) {
        for i in offset..<(offset + count) {
            page.messages.addObject( self.messages.objectAtIndex(i) )
        }
    }
    
    func setUpPanels() {
        if _initialized == true {
            self.resetPanels()
        }
        
        var oriented: String = self.getOrientation()

        let div: CGFloat = oriented == "Portrait" ? 1.0 : 0.5
        let perPage = CGFloat(self.perPage) * div
        let _pages: Int = Int(ceil( CGFloat(self.messages.count / Int(perPage))  ))

        var scrollFrame: CGRect = self._originFrame // getPanelBounds()
        var pageFrame: CGRect   = self._originFrame
        pageFrame.size.width    *= oriented == "Portrait" ? CGFloat(_pages) : 0
        pageFrame.size.height   *= oriented == "Portrait" ? 1.0 : CGFloat(_pages)
        var len:Int = Int(perPage)
        
        var page:MessagePanelView
        var xCorrect : CGFloat    = 0.0
        if UIScreen.mainScreen().nativeBounds.size.width > 1900.00 || UIScreen.mainScreen().nativeBounds.size.height > 1900.00 {
            xCorrect = -5.0
        }
        
        for index in 0..<_pages {
            let loc = index*len
            var frame: CGRect
            let xOffset: CGFloat = (UIScreen.mainScreen().bounds.size.width)// + 2.0
            if oriented == "Portrait" {
//                * CGFloat(index)
                frame = CGRect(x: xOffset * CGFloat(index), y: 0, width: (UIScreen.mainScreen().bounds.size.width), height: self.scrollView.bounds.height)
//                frame.origin.x = CGFloat(frame.width * CGFloat(index)) //- CGFloat(5 * (index + 1))
                frame.origin.x += (xCorrect * CGFloat(index + 1))
                frame.origin.y = 30.0
                pageFrame.size.width = frame.width * CGFloat(index + 1)
            }
            else {
                frame = CGRect(x: 0, y: 0, width: (UIScreen.mainScreen().bounds.size.width) * div, height: self.scrollView.bounds.height)
                frame.origin.y = 30.0 //frame.size.width
                frame.origin.x = (frame.size.width ) * CGFloat(index)
                pageFrame.size.width    += frame.size.width
                pageFrame.size.height   =  self.scrollView.frame.height
            }
            
            page = createPanel(index, frame: frame)
            assignMessagesToPage(page, offset: Int(loc), count: len)
            pages.append(page)
            scrollView.addSubview( page )
        }
        
        var size:CGSize = CGSizeMake(pageFrame.size.width, pageFrame.size.height)
        
        pager.currentPage = 0
        pager.numberOfPages = Int( CGFloat(_pages) * div )
        scrollView.pagingEnabled    = true
        scrollView.contentSize = size
//        scrollView.backgroundColor = UIColor.blueColor()
        _initialized = true
    }
    
    func resetPanels() {
        self.pages.removeAll(keepCapacity: true)
        pager.numberOfPages = 0
        for subview in self.scrollView.subviews
        {
            subview.removeFromSuperview()
        }

    }
    
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        scrollView.scrollRectToVisible(frame, animated: animated)
    }
    
//    func setNavBGImage() -> UIImage {
//        UIGraphicsBeginImageContext(self.navView.frame.size)
//        UIImage(named: "bot_barbg.png" )?.drawAsPatternInRect(self.navView.bounds)
//        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
        
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self._originFrame = scrollView.bounds
        pager.hidesForSinglePage = true
        self.initializeData()
        setupSize()

        
        self.nextKeyboard.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        self.setUpPanels()
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        setupSize()
        self.setUpPanels()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.setUpPanels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.setUpPanels()
    }
    
    //override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    //}

    // override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
    
//        var textColor: UIColor
//        var proxy = self.textDocumentProxy as! UITextDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
//            textColor = UIColor.whiteColor()
//        } else {
//            textColor = UIColor.blackColor()
//        }
////        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
   // }

}
