//
//  SubCellPickList.m
//  Heya
//
//  Created by jayantada on 28/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "SubCellPickList.h"

@implementation SubCellPickList
@synthesize subTextLabel;
@synthesize checkMarkImage;
@synthesize cellEditBtn;
@synthesize topSeperator;
@synthesize indexPath;

- (void)awakeFromNib
{
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
