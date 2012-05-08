//
//  ShareViewController.h
//  iquotes
//
//  Created by Shi Forrest on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController < UIActionSheetDelegate >
{
    IBOutlet UITextView   *textView;

}

- (IBAction)publishToMyFBWall:(id)sender;

@end
