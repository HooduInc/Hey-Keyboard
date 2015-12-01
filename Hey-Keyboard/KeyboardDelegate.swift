//
//  KeyboardDelegate.swift
//  HeyaKeyboard
//
//  Created by Van Carney on 5/3/15.
//  Copyright (c) 2015 Van Carney. All rights reserved.
//
import UIKit
import Foundation

struct KeyboardDelegate  {
    var inputView: UIInputViewController!
    var suiteName: String = "group.V832NBX5Y5.com.hooduinc.HeyKeyboard";
    
    init(parent: UIInputViewController) {
        self.inputView = parent
        let preferences = NSUserDefaults(suiteName:self.suiteName);
        let applicationInstalledDate = NSDate();
        let hasLaunched = preferences!.boolForKey("HasLaunchedOnce")
        if !(hasLaunched) {
            preferences!.setBool(true, forKey:"HasLaunchedOnce");
            preferences!.setObject("Standard", forKey:"themeName");
            preferences!.setObject("Standard", forKey:"themeName");
            preferences!.setValue( applicationInstalledDate, forKey:"applicationInstalledDate");
            preferences!.setBool(true, forKey:"shareHey");
            preferences!.synchronize();
            
            DBManager.checkAndCreateDatabase();
         }
    }
    
    
    func insertText(string:String) {
        var proxy: UITextDocumentProxy = self.inputView.textDocumentProxy as! UITextDocumentProxy
        proxy.insertText(string as String)
//        self.inputView.dismissKeyboard()
        self.inputView.advanceToNextInputMode()
    }
}
