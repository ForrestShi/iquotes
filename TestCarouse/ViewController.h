//
//  ViewController.h
//  TestCarouse
//
//  Created by Shi Forrest on 12-5-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface ViewController : UIViewController

@property (nonatomic,strong) IBOutlet iCarousel *carousel;
@property (nonatomic,strong) IBOutlet UIView    *facebookView;
@property (nonatomic,strong) IBOutlet UIImageView  *bacgroundImageView;

//- (IBAction)publishToMyFBWall:(id)sender;

@end
