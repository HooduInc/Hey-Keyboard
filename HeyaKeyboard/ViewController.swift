//
//  ViewController.swift
//  HeyaKeyboard
//
//  Created by Van Carney on 4/28/15.
//  Copyright (c) 2015 Van Carney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var menuWIdth: NSLayoutConstraint!
    @IBOutlet weak var menuHeight: NSLayoutConstraint!
    
//    - (IBAction)selectThemeButtonTapped:(id)sender {
//    
//    ThemeViewController *tVc = [[ThemeViewController alloc] initWithNibName:@"ThemeViewController" bundle:nil];
//    [self.navigationController pushViewController:tVc animated:YES];
//    
//    
//    }
    @IBAction func selectThemeButtonTapped(sender: UIButton){
        
    }
//    
//    - (IBAction)pickListButton:(id)sender {
//    
//    PickFromListController *pickListController = [[PickFromListController alloc] initWithNibName:@"PickFromListController" bundle:nil];
//    pickListController.FlagFromSettings=YES;
//    [self.navigationController pushViewController:pickListController animated:YES];
//    }

    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var screen: UIScreen = UIScreen.mainScreen()
        menuHeight.constant = screen.bounds.height
        menuWIdth.constant = screen.bounds.width
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

