//
//  ViewController.m
//  TestCarouse
//
//  Created by Shi Forrest on 12-5-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "QuotesManager.h"
#import "QuoteObject.h"
#import "QuoteView.h"
#import "ShareViewController.h"
#import "SCFacebook.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define NUMBER_OF_ITEMS (IS_IPAD? 19: 12)
#define NUMBER_OF_VISIBLE_ITEMS 25
#define ITEM_SPACING 210.0f
#define INCLUDE_PLACEHOLDERS YES

#define QUOTEVIEW_FRAME_X 50.0f
#define QUOTEVIEW_FRAME_Y 50.0f
#define QUOTEVIEW_FRAME_WIDTH 1024 - QUOTEVIEW_FRAME_X*2
#define QUOTEVIEW_FRAME_HEIGHT 768 - QUOTEVIEW_FRAME_Y*2


@interface ViewController() <iCarouselDataSource, iCarouselDelegate , UIGestureRecognizerDelegate > {
@private
    ShareViewController *_shareVC ;
    BOOL                _isShowSocialView;
    NSString            *_currentQuoteText;
    NSTimer             *changeBgTimer ;
}
@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSMutableArray *peoples;
@property (nonatomic, strong) NSMutableArray *quotes;
@property (nonatomic, strong) ShareViewController *shareVC;
@end


@implementation ViewController
@synthesize carousel = _carousel;
@synthesize wrap;
@synthesize peoples;
@synthesize quotes;
@synthesize facebookView;
@synthesize shareVC = _shareVC;
@synthesize bacgroundImageView;


- (void)setUp
{
	//set up data
	wrap = YES;
	self.peoples = [NSMutableArray array];
	for (int i = 0; i < NUMBER_OF_ITEMS; i++)
	{
		[peoples addObject:[NSNumber numberWithInt:i]];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setUp];
    }
    return self;
}


- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:nil];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (quotes) {
        [quotes removeAllObjects];
        quotes = nil;
    }
    if (!quotes) {
        NSString *plist1Path = [[NSBundle mainBundle] pathForResource:@"jobs_quotes" ofType:@"plist" ];
        quotes = [[[QuotesManager alloc] initWithPlist:plist1Path] quotesArray];
    }
    
    if (_carousel) {
        _carousel.delegate = self;
        _carousel.dataSource = self;
        
        //configure carousel
        _carousel.decelerationRate = 2.5;
        _carousel.type = iCarouselTypeCylinder;
        _carousel.vertical = YES;
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"shake" object:nil queue:nil usingBlock:^(NSNotification *note) {
        //
        DLog(@"%s", __PRETTY_FUNCTION__);
        _carousel.type = rand()%iCarouselTypeCustom;
    }];
    
    //dynamic background images
    static int count = 0;
    NSArray *imageNameArray = [NSArray arrayWithObjects:
                               @"3.jpeg",
                               @"5.jpeg",
                               @"60.jpg",
                               @"38.jpg",
                               @"0.jpg",
                               @"113.png",
                               @"8.jpeg"
                            
                               @"5.jpg",
                               @"deer.jpg",
                               @"john.jpg",
                               @"moon_light.jpg",
                               @"blue_rays.jpg",
                               @"28.jpg",
                               @"71.jpg",
                               @"1.jpg",
                               @"bill_gates.png",nil];
    
    changeBgTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 block:^(NSTimeInterval time) {
        NSString *imageName = [imageNameArray objectAtIndex:(count++)%[imageNameArray count] ];
        
        BOOL animated = YES;
        
        if (animated) {
            CATransition *transition = [CATransition animation];
            transition.duration = 2.5f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [bacgroundImageView.layer addAnimation:transition forKey:@"image"];
        }

        bacgroundImageView.image = [UIImage imageNamed:imageName];
        
    } repeats:YES];
    

    // Swip action 
    UISwipeGestureRecognizer *swipLeftGesture = [[UISwipeGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UISwipeGestureRecognizer *swip = (UISwipeGestureRecognizer*)sender;
        
        if (state == UIGestureRecognizerStateEnded) {
            NSLog(@"%d directi on %d", [NSThread isMainThread] , [swip direction]);

            [UIView animateWithDuration:1.0 animations:^{
                self.carousel.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }];
    swipLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipLeftGesture.numberOfTouchesRequired = 1;
    
    UISwipeGestureRecognizer *swipRightGesture = [[UISwipeGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UISwipeGestureRecognizer *swip = (UISwipeGestureRecognizer*)sender;
        
        if (state == UIGestureRecognizerStateEnded) {
            NSLog(@"%d directi on %d", [NSThread isMainThread] , [swip direction]);
            
            [UIView animateWithDuration:1.0 animations:^{
                self.carousel.alpha = 0.0;
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }];
    swipRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    swipRightGesture.numberOfTouchesRequired = 1;
    
    swipLeftGesture.delegate = self;
    swipRightGesture.delegate = self;
    //Swip left/right to make carousel visible/invisible 
    [self.view addGestureRecognizer:swipLeftGesture];
    [self.view addGestureRecognizer:swipRightGesture];

    // does not show carousel when launching 
    self.carousel.alpha = 0.0;
    _isShowSocialView = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -  gesture delegate

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if ([touch.view isKindOfClass:[UIButton class]]) {
            return NO;
        }
    }else if([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class ]]){
        if (_isShowSocialView) {
            return NO;
        }
    }
    return YES;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void) swipAction:(UISwipeGestureRecognizer*)sender{
    
        
}
#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [peoples count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    //this also affects the appearance of circular-type carousels
    return NUMBER_OF_VISIBLE_ITEMS;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	UILabel *label = nil;
	
	//create new view if no view is available for recycling
	if (view == nil)
	{
        view = [[QuoteView alloc] initWithFrame:CGRectMake(QUOTEVIEW_FRAME_X, QUOTEVIEW_FRAME_Y, 
                                                           QUOTEVIEW_FRAME_WIDTH,QUOTEVIEW_FRAME_HEIGHT)];
		label = [[UILabel alloc] initWithFrame:view.bounds];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [label.font fontWithSize:50];
		[view addSubview:label];
        view.alpha = 0.95;
        
        view.layer.shadowColor = [[UIColor blackColor] CGColor];
        view.layer.shadowOffset = CGSizeMake(25.0f, 25.0f);
        view.layer.shadowOpacity = 1.0f;
        view.layer.shadowRadius = 25.0f;
        view.layer.shouldRasterize = YES;        
	}
	else
	{
		label = [[view subviews] lastObject];
	}
	
    //set label
    QuoteView  *quoteView = (QuoteView*)view;
    quoteView.backgroundColor = [UIColor blackColor];
    
    quoteView.peopleImage = [UIImage imageNamed:@"steve.png"];
    
    NSInteger quotesTotalNum = [quotes count];
    if (quotesTotalNum > 0 ) {
        QuoteObject *quote = (QuoteObject*)[self.quotes objectAtIndex:index%quotesTotalNum];
        quoteView.quoteText = quote.quoteText;
    }


	return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	//note: placeholder views are only displayed on some carousels if wrapping is disabled
	return INCLUDE_PLACEHOLDERS? 2: 0;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	UILabel *label = nil;
	
	//create new view if no view is available for recycling
	if (view == nil)
	{
		view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page.png"]];
		label = [[UILabel alloc] initWithFrame:view.bounds];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [label.font fontWithSize:50.0f];
		[view addSubview:label];
	}
	else
	{
		label = [[view subviews] lastObject];
	}
	
    //set label
	label.text = (index == 0)? @"[": @"]";
	
	return view;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return QUOTEVIEW_FRAME_WIDTH; //600.0f + 50.0f; //ITEM_SPACING;
}

- (CGFloat)carousel:(iCarousel *)carousel itemAlphaForOffset:(CGFloat)offset
{
	//set opacity based on distance from camera
    return 1.0f - fminf(fmaxf(offset, 0.0f), 1.0f);
}

- (CATransform3D)carousel:(iCarousel *)aCarousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * aCarousel.itemWidth);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return wrap;
}


- (void) captureCurrentQuote:(NSInteger)index carousel:(iCarousel*)carousel asImage:(UIImage**)capturedImage{
    UIView  *cellView = [carousel itemViewAtIndex:index];
    cellView.alpha = 1.0;
    CGRect rect =cellView.frame;  
    UIGraphicsBeginImageContext(rect.size);  
    CGContextRef context = UIGraphicsGetCurrentContext();  
    [cellView.layer renderInContext:context];  
    UIImage *imageCaptureRect = UIGraphicsGetImageFromCurrentImageContext();  
    *capturedImage = imageCaptureRect;
    UIGraphicsEndImageContext();
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    DLog(@"%s",__PRETTY_FUNCTION__);
    
    QuoteObject *currentQuote =  [self.quotes objectAtIndex:index % [self.quotes count]];
    _currentQuoteText = [currentQuote quoteText];
    
    UIView  *cellView = [carousel itemViewAtIndex:index];
    __block UIImage *cellImage = nil;
    dispatch_queue_t capture_queue = dispatch_queue_create("capture", NULL);
    dispatch_async(capture_queue, ^{
        [self captureCurrentQuote:index carousel:carousel asImage:&cellImage];
   
    });

    DLog(@"current quote %@", _currentQuoteText);
    if (!_shareVC) {
            _shareVC = [[ShareViewController alloc] initWithFrame:cellView.frame quoteText:_currentQuoteText quoteImage:cellImage];
        
//        _shareVC.view.layer.shadowColor = [[UIColor blackColor] CGColor];
//        _shareVC.view.layer.shadowOffset = CGSizeMake(50.0, 20.0);
//        _shareVC.view.layer.shadowOpacity = 1.0;
//        _shareVC.view.layer.shadowRadius = 50.0f;
//        _shareVC.view.layer.masksToBounds = YES;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_shareVC.view.frame byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(50, 50)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = _shareVC.view.frame;
        maskLayer.path = path.CGPath;
        _shareVC.view.layer.mask = maskLayer;

    }else {
        _shareVC.quoteText = _currentQuoteText;
        _shareVC.quoteImage = cellImage;
    }

    UIView  *shareView  = _shareVC.view;

    [UIView transitionFromView:cellView toView:shareView duration:.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
        if (finished) {
            //remove all gestures for carouse 
            [self.carousel setIgnoreAllGestures:YES];
            
            _isShowSocialView = YES;
            
            UIButton *backButton = (UIButton*)[shareView viewWithTag:1001];
            [backButton addEventHandler:^(id sender) {
                //flip back by tapping 
                [UIView transitionFromView:shareView toView:cellView duration:.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
                    //
                    [self.carousel setIgnoreAllGestures:NO];
                    _isShowSocialView = NO;
                    
                }];
            } forControlEvents:UIControlEventTouchUpInside];

        }
    }];
}
 
@end