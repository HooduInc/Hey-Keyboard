//
//  ThemeViewController.h
//  Heya
//
//  Created by jayantada on 02/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface ThemeViewController : UIViewController<iCarouselDataSource, iCarouselDelegate>


@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet iCarousel *carousel;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIButton *selectThemeButton;
@property (nonatomic) BOOL wrap;
@property (nonatomic, strong) NSUserDefaults *preferences;
@property (strong, nonatomic) UIView *generatedView;
@property (strong, nonatomic) UIImageView *img1;
@property (strong, nonatomic) UIImageView *img2;
@property (strong, nonatomic) UIImageView *img3;
@property (strong, nonatomic) UIImageView *generatedimage;
@property (strong, nonatomic) NSMutableArray *theme , *themeName;
@property (strong, nonatomic) NSArray *brightArray, *standardArray, *oneColorArray,*outLineArray,*mutedArray;

@property (nonatomic, retain) NSMutableArray *msglist_arr, *subMenuMsgArray;

- (IBAction)selectThemeButton:(id)sender;

@end
