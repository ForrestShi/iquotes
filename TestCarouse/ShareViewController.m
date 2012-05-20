//
//  ShareViewController.m
//  iquotes
//
//  Created by Shi Forrest on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <Twitter/twitter.h>
#import <QuartzCore/QuartzCore.h>

#import "ShareViewController.h"
#import "SCFacebook.h"
#import "QuotesManager.h"

@interface ShareViewController () <MFMailComposeViewControllerDelegate >{
@private
    UIView *loadingView; 
    NSString *_indexString;
    
    NSString *_quoteText;
}

-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;

@end

@implementation ShareViewController

@synthesize quoteText = _quoteText;
@synthesize quoteImage = _quoteImage;
@synthesize indexString = _indexString;
@synthesize quoteIndex = _quoteIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame quoteText:(NSString*)quote quoteImage:(UIImage*)image indexString:(NSString*)idx{
    self = [super initWithNibName:@"ShareViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.view.frame = frame;
        _quoteText = quote;
        _quoteImage = image;
        _indexString = idx;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(50, 50)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.view.frame;
        maskLayer.path = path.CGPath;
        self.view.layer.mask = maskLayer;

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
            
            indexLabel.text = _indexString;
            
        } afterDelay:.5];
    }
    
    //background texture
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern1.jpg"]];
    
    
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
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void) setQuoteText:(NSString *)quoteText{    
    _quoteText = quoteText;
    [textView setText:[NSString stringWithFormat:@"%@ --- Steve Jobs ", _quoteText]];
}

- (void) setIndexString:(NSString *)indexString{
    _indexString = indexString;
    [indexLabel setText:_indexString];
}

#pragma mark - Facebook actions


- (IBAction)publishToMyFBWall:(id)sender{
    
    loadingView.hidden = NO;
    
    [SCFacebook loginCallBack:^(BOOL success, id result) {
        
        loadingView.hidden = YES;
       if (success) {
            DLog(@"succeed to login");
//            loadingView.hidden = NO;
//
//            [SCFacebook feedPostWithAppStore:_quoteText callBack:^(BOOL success, id result) {
//                loadingView.hidden = YES;
//
//                if (success) {
//                    DLog(@"succeed to post msg to fb");
//                } 
//            }];
       }else {
           //
           DLog(@"Failed to login FB");
       }
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

-(IBAction)sendEmail:(id)sender
{
    // This sample can run on devices running iPhone OS 2.0 or later  
    // The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
    // So, we must verify the existence of the above class and provide a workaround for devices running 
    // earlier versions of the iPhone OS. 
    // We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
    // We launch the Mail application on the device, otherwise.
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}


#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@""];
        
    // Attach an image to the email
    NSData *myData = UIImagePNGRepresentation(_quoteImage);
    [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
    
    // Fill out the email body text
    NSString *emailBody = @"Stay hungry,stay foolish. --- Steve Jobs";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:picker animated:YES];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    message.hidden = NO;
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            message.text = @"Result: canceled";
            break;
        case MFMailComposeResultSaved:
            message.text = @"Result: saved";
            break;
        case MFMailComposeResultSent:
            message.text = @"Result: sent";
            break;
        case MFMailComposeResultFailed:
            message.text = @"Result: failed";
            break;
        default:
            message.text = @"Result: not sent";
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:first@example.com&subject=Hello from California!";
    NSString *body = @"&body=Stay hungry,stay foolish!";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


#pragma mark - Awesome Menu Delegate 

- (IBAction)bookmarkQuote:(id)sender{
    [[QuotesManager shareInstance] bookmarkQuote:_quoteIndex];
}
@end
