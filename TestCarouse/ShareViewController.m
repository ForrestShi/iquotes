//
//  ShareViewController.m
//  iquotes
//
//  Created by Shi Forrest on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "SCFacebook.h"

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    [self.view addSubview:loadingView];
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


- (void)publishYourWall:(id)sender 
{
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"Option Publish"
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:@"Cancel"
                            otherButtonTitles:@"Link", @"Message", @"Message Dialog", @"Photo", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[sheet showFromRect:self.view.bounds inView:self.view animated:YES];
}


- (IBAction)publishToMyFBWall:(id)sender{
    
    loadingView.hidden = NO;
    
    [SCFacebook loginCallBack:^(BOOL success, id result) {
        loadingView.hidden = YES;
        
        if (success) {
            //[self publishYourWall:sender];
            // DLog(@"%s", __PRETTY_FUNCTION__);
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lucascorrea.com/lucas_apple.png"]]];
            loadingView.hidden = NO;
//            [SCFacebook feedPostWithPhoto:image caption:@"This is message with photo" callBack:^(BOOL success, id result) {
//                loadingView.hidden = YES;
//            }];

            [SCFacebook feedPostWithAppStore:@"I am using Steve Jobs Quotes" callBack:^(BOOL success, id result) {
                loadingView.hidden = YES;
            }];
            
            
        }
    }];
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == actionSheet.destructiveButtonIndex) { return; }
    
    switch (buttonIndex) {
            
            //Link
		case 1:{
            loadingView.hidden = NO;
            [SCFacebook feedPostWithLinkPath:@"http://www.lucascorrea.com" caption:@"Portfolio" callBack:^(BOOL success, id result) {
                loadingView.hidden = YES;
            }];
            break;
		}
            
            //Message
		case 2:{
            loadingView.hidden = NO;
            [SCFacebook feedPostWithMessage:@"This is message" callBack:^(BOOL success, id result) {
                loadingView.hidden = YES;
            }];
            break;
		}
            //Message Dialog
		case 3:{
            
            [SCFacebook feedPostWithMessageDialogCallBack:^(BOOL success, id result) {
            }];
            break;
		}
            //Photo
        case 4:{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lucascorrea.com/lucas_apple.png"]]];
            loadingView.hidden = NO;
            [SCFacebook feedPostWithPhoto:image caption:@"This is message with photo" callBack:^(BOOL success, id result) {
                loadingView.hidden = YES;
            }];
            break;
		}
	}
}


@end
