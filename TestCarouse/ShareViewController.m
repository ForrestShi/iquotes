//
//  ShareViewController.m
//  iquotes
//
//  Created by Shi Forrest on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <Twitter/twitter.h>

#import "ShareViewController.h"
#import "SCFacebook.h"

@interface ShareViewController () {
@private
    UIView *loadingView; 
    NSString *_quoteText;
}
@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame quoteText:(NSString*)quote{
    self = [super initWithNibName:@"ShareViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.view.frame = frame;
        _quoteText = quote;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //Loading
    
    loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
	loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
	UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[loadingView addSubview:aiView];
	[aiView startAnimating];
	aiView.center =  loadingView.center;
	loadingView.hidden = YES;
    [self.view addSubview:loadingView];
    
    //textfield
    
    if (textView) {
        [self performBlock:^(id sender) {
            //
            textView.alpha = 0;
            textView.text = [NSString stringWithFormat:@"%@ -- Steve Jobs ", _quoteText];
            [UIView animateWithDuration:1.5 animations:^{
                textView.alpha = 1.0;
            }];
            
        } afterDelay:.5];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Facebook actions

- (void)getUserInfo
{
    loadingView.hidden = NO;
    
    [SCFacebook getUserFQL:FQL_USER_STANDARD callBack:^(BOOL success, id result) {
        if (success) {
            NSLog(@"%@", result);
            
            loadingView.hidden = YES;
        }else{
            
            loadingView.hidden = YES;
            
        }
    }];
}


- (IBAction)publishToMyFBWall:(id)sender{
    
    loadingView.hidden = NO;
    
    [SCFacebook loginCallBack:^(BOOL success, id result) {
        
        if (success) {
            DLog(@"succeed to login");
            
            [SCFacebook feedPostWithAppStore:_quoteText callBack:^(BOOL success, id result) {
                if (success) {
                    DLog(@"succeed to post msg to fb");
                } 
                loadingView.hidden = YES;
            }];
        }
        
        loadingView.hidden = YES;
        
    }];
    
}

- (IBAction)inviteFBFriendsToUseThisApp:(id)sender{
    
    [SCFacebook inviteFriendsWithMessage:@"Come on,check out what Steve Jobs said" callBack:^(BOOL success, id result) {
        if (success) {
            DLog(@"succeed to invite");
        }else
        {
            UIAlertView *alertView = [[UIAlertView alloc] 
                                      initWithTitle:@"Sorry"                                                             
                                      message:@"You can't invite friends right now, make sure you have login in Facebook already"                                                          
                                      delegate:self                                              
                                      cancelButtonTitle:@"OK"                                                   
                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
}
- (IBAction)sendToTwitter:(id)sender{
    
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet = 
        [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:_quoteText];
        [self presentModalViewController:tweetSheet animated:YES];
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:@"Sorry"                                                             
                                  message:@"You can't invite right now, make sure your device has an internet connection and you have at least one Twitter account setup"                                                                                                                    
                                  delegate:self                                              
                                  cancelButtonTitle:@"OK"                                                   
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (IBAction)emailSend:(id)sender{
    
}

@end
