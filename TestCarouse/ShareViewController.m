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
    UITextView *quoteTextView; 
    
}
@property (nonatomic, strong) NSString *quoteText;
@property (nonatomic, strong) UIImage  *quoteImage;
@property (nonatomic, strong) NSString *indexString;
@property (nonatomic) NSUInteger quoteIndex;
@property (nonatomic) BOOL bookmarkType;


-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;

@end

@implementation ShareViewController

@synthesize quoteText = _quoteText;
@synthesize quoteImage = _quoteImage;
@synthesize indexString = _indexString;
@synthesize quoteIndex = _quoteIndex;
@synthesize bookmarkType = _bookmarkType;

@synthesize delegate;

- (id) initWithFrame:(CGRect)frame 
           quoteText:(NSString*)quote 
          quoteImage:(UIImage*)image 
         indexString:(NSString*)idx
               index:(NSUInteger)index
            bookmark:(BOOL)yesOrNo{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.frame = frame;
        _quoteText = quote;
        _quoteImage = image;
        _indexString = idx;
        _quoteIndex = index;
        _bookmarkType = yesOrNo;
        
        //
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake( IS_IPAD ? 25 : 15, IS_IPAD ? 25 : 15)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.view.frame;
        maskLayer.path = path.CGPath;
        self.view.layer.mask = maskLayer;
    }
    return self;
}

- (void) buildUI{
    //back button 
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(GAPX, GAPY, BUTTONWIDTH, BUTTONHEIGHT)];
    [backButton setImage: [UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    //status label 
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - BUTTONWIDTH, GAPY, BUTTONWIDTH*3, BUTTONHEIGHT)];
    statusLabel.text = _indexString;
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.font = [UIFont fontWithName:@"Kailasa" size:IS_IPAD ? 25 : 15];
    statusLabel.textColor = [UIColor yellowColor];
    statusLabel.textAlignment = UITextAlignmentCenter;
    
    [self.view addSubview:statusLabel];
    
    
    
    //textView
     quoteTextView = [[UITextView alloc] initWithFrame:CGRectMake(GAPX, 
                                                                             GAPY + backButton.frame.size.height + 10,
                                                                             self.view.bounds.size.width - GAPX*2,
                                                                             self.view.bounds.size.height *.5)];
    
    quoteTextView.alpha = 0;
    quoteTextView.font = [UIFont fontWithName:@"Noteworthy-Light" size:FONT_SIZE_MIDDLE];

    quoteTextView.text = [NSString stringWithFormat:@"%@ -- Steve Jobs ", _quoteText];
        
    float shadowSize = 10.0f;
    quoteTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    quoteTextView.layer.shadowOffset = CGSizeMake(-shadowSize,shadowSize);
    quoteTextView.layer.shadowOpacity = .8f;
    quoteTextView.layer.shadowRadius = shadowSize/2;
    quoteTextView.layer.shouldRasterize = YES;  
    
    
    if ( _bookmarkType || [[QuotesManager shareInstance] isBookmarked:_quoteIndex] ) {
        [UIView animateWithDuration:0.8 animations:^{
            quoteTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"parchment.jpg"]]; 
            quoteTextView.alpha = .8;
        }];
    }else {
        [UIView animateWithDuration:0.8 animations:^{
            quoteTextView.backgroundColor = [UIColor lightGrayColor]; 
            quoteTextView.alpha = .8;
        }];
    }    [self.view addSubview:quoteTextView];
    
    
    //add bookmark button
    
    if (!_bookmarkType ) {
        UIButton *bookmarkButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - BUTTONWIDTH *2, GAPY, BUTTONWIDTH, BUTTONHEIGHT)];
        [bookmarkButton addTarget:self action:@selector(bookmark:) forControlEvents:UIControlEventTouchUpInside];
        [bookmarkButton setImage:[UIImage imageNamed:@"love.png"] forState:UIControlStateNormal];
        
        [self.view addSubview:bookmarkButton];
    }

    //share buttons
    for (int i = 0 ; i < 4; i++) {
         __strong UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(GAPX + i * ( BUTTONWIDTH + GAPX ), 
                                                                           quoteTextView.frame.origin.y + quoteTextView.frame.size.height + GAPY  ,
                                                                           BUTTONWIDTH,
                                                                           BUTTONHEIGHT)];
        
        if (i == 0 ) {
            [shareButton addTarget:self action:@selector(publishToMyFBWall:) forControlEvents:UIControlEventTouchUpInside];
            [shareButton setImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
        }else if (i == 1 ) {
            [shareButton addTarget:self action:@selector(sendToTwitter:) forControlEvents:UIControlEventTouchUpInside];
            [shareButton setImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
        }else if (i == 2 ) {
            [shareButton addTarget:self action:@selector(sendEmail:) forControlEvents:UIControlEventTouchUpInside];
            [shareButton setImage:[UIImage imageNamed:@"mail_black.png"] forState:UIControlStateNormal];
        }else if (i == 3 ) {
            [shareButton addTarget:self action:@selector(inviteFBFriendsToUseThisApp:) forControlEvents:UIControlEventTouchUpInside];
            [shareButton setImage:[UIImage imageNamed:@"invite.png"] forState:UIControlStateNormal];
        }        
        [self.view addSubview:shareButton];
    }

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

    //double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 /*delayInSeconds * NSEC_PER_SEC*/);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self buildUI];
    });
    
    //Loading
    
    loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
	loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
	UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[loadingView addSubview:aiView];
	[aiView startAnimating];
	aiView.center =  loadingView.center;
	loadingView.hidden = YES;
    [self.view addSubview:loadingView];
    
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
    if (_quoteImage) {
        NSData *myData = UIImagePNGRepresentation(_quoteImage);
        [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
    }
    // Fill out the email body text
    NSString *emailBody = _quoteText ;// @"Stay hungry,stay foolish. --- Steve Jobs";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:picker animated:YES];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:first@example.com&subject=Jobs Quotes!";
    NSString *body = _quoteText;
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


#pragma mark - Awesome Menu Delegate 

- (void)bookmark:(id)sender{
    DLog(@"%s",__PRETTY_FUNCTION__);

    if ([[QuotesManager shareInstance] bookmarkQuote:_quoteIndex]) {
        [UIView animateWithDuration:0.8 animations:^{
            quoteTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"parchment.jpg"]]; 
        }];
    }else {
        [UIView animateWithDuration:0.8 animations:^{
            quoteTextView.backgroundColor = [UIColor lightGrayColor]; 
        }];
    }

}

- (void)back:(id)sender{
    if (delegate) {
        [delegate flipBack];
    }
}
@end
