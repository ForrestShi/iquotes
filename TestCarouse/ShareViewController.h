//
//  ShareViewController.h
//  iquotes
//
//  Created by Shi Forrest on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController 
{
    IBOutlet UITextView   *textView;

}

- (id) initWithFrame:(CGRect)frame quoteText:(NSString*)quote;

- (IBAction)publishToMyFBWall:(id)sender;
- (IBAction)inviteFBFriendsToUseThisApp:(id)sender;
- (IBAction)sendToTwitter:(id)sender;
- (IBAction)emailSend:(id)sender;

@end
