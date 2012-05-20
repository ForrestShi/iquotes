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
#import "CategoryViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define NUMBER_OF_ITEMS 1000
#define NUMBER_OF_VISIBLE_ITEMS (IS_IPAD? 5: 5)

#define ITEM_SPACING 210.0f
#define INCLUDE_PLACEHOLDERS NO

#define QUOTEVIEW_FRAME_X 80.0f
#define QUOTEVIEW_FRAME_Y 80.0f
#define QUOTEVIEW_FRAME_WIDTH 1024 - QUOTEVIEW_FRAME_X*2
#define QUOTEVIEW_FRAME_HEIGHT 768 - QUOTEVIEW_FRAME_Y*2

typedef enum{
    CATEGORY,
    QUOTE
} VIEWTYPE;

@interface ViewController() <iCarouselDataSource, iCarouselDelegate , UIGestureRecognizerDelegate > {
@private
    BOOL                _isShowSocialView;
    NSString            *_currentQuoteText;
    NSTimer             *changeBgTimer ;
    iCarousel           *_quotesView;
    CategoryViewController *_categoryVC;
    
}
@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSArray *quotes;
@property (nonatomic, strong) ShareViewController *shareVC;
@end


@implementation ViewController
@synthesize wrap;
@synthesize quotes;
@synthesize shareVC = _shareVC;
@synthesize bacgroundImageView;


- (void)setUp
{
	//set up data
	wrap = NO;
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

#pragma mark - Shake Motion

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
    if (!quotes) {
        quotes = [[QuotesManager shareInstance] quotesArray];
    }
    
    // Quote View
    CGRect viewBounds = self.view.bounds;
    if (!_quotesView) {
        _quotesView = [[iCarousel alloc] initWithFrame:viewBounds];
        _quotesView.delegate = self;
        _quotesView.dataSource = self;
        
        //configure carousel
        _quotesView.decelerationRate = 2.5;
        _quotesView.type = iCarouselTypeInvertedWheel;
        _quotesView.vertical = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"shake" object:nil queue:nil usingBlock:^(NSNotification *note) {
        //
        DLog(@"%s", __PRETTY_FUNCTION__);
        _quotesView.type = rand()%iCarouselTypeCustom;
    }];
    [self.view addSubview:_quotesView];
    
    if (!_categoryVC) {
        _categoryVC = [[CategoryViewController alloc] init];
        _categoryVC.view.frame = CGRectMake(viewBounds.origin.x - viewBounds.size.width, viewBounds.origin.y, viewBounds.size.width, viewBounds.size.height);
    }
    _categoryVC.view.alpha = 0.0;
    [self.view addSubview:_categoryVC.view];
    
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
            
            __block CGPoint oldCenter = _quotesView.center;
            
            [UIView animateWithDuration:1.0 animations:^{
                float newX = oldCenter.x - self.view.bounds.size.width*0.9;
                if (newX > 1024/4) {
                    //come back to reader mode
                    _quotesView.center = CGPointMake(newX , oldCenter.y);
                    [_quotesView setIgnoreAllGestures:NO];
                }
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    _categoryVC.view.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0);
                    _categoryVC.view.alpha = 0.0;
                    
                }];
            }];
            
        }
    }];
    swipLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipLeftGesture.numberOfTouchesRequired = 1;
    
    // SHOW CATEGORY VIEW 
    UISwipeGestureRecognizer *swipRightGesture = [[UISwipeGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UISwipeGestureRecognizer *swip = (UISwipeGestureRecognizer*)sender;
        
        if (state == UIGestureRecognizerStateEnded) {
            NSLog(@"%d directi on %d", [NSThread isMainThread] , [swip direction]);
            __block CGPoint oldCenter = _quotesView.center;
            
            [UIView animateWithDuration:1.0 animations:^{
                
                float newX = oldCenter.x + self.view.bounds.size.width*0.9;
                if (newX < self.view.bounds.size.width + 1024/2) {
                    [_quotesView setIgnoreAllGestures:YES];
                    _quotesView.center = CGPointMake(newX , oldCenter.y); 
                }
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    _categoryVC.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0);
                    _categoryVC.view.alpha = 1.0;
                    
                }];
                
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
    
    _isShowSocialView = NO;
    
    // handle actions of selecting category
    [[NSNotificationCenter defaultCenter] addObserverForName:@"select_category" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        //
        NSUInteger category_index = [[[note userInfo] objectForKey:@"category_index"] intValue];
        DLog(@"%s index %d",__PRETTY_FUNCTION__ , category_index);
        //set the data source for the specified category 
        //TODO
        switch (category_index) {
            case 0:
            {
                quotes = [[QuotesManager shareInstance] quotesArray];
                break;
            }   
            case 1:
            {
                quotes = [[QuotesManager shareInstance] bookmarkQuotes];
                break;
            }
            default:
                break;
        }
        //transition of views
        __block CGPoint oldCenter = _quotesView.center;
        [UIView animateWithDuration:.5 animations:^{
            
            _categoryVC.view.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0);
            _categoryVC.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:1.0 animations:^{
                
                float newX = oldCenter.x - self.view.bounds.size.width*0.9;
                if (newX > 1024/4) {
                    //come back to reader mode
                    _quotesView.center = CGPointMake(newX , oldCenter.y);
                    [_quotesView setIgnoreAllGestures:NO];
                }
                
            }];
            
        }];
        
    }];
    
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
    }else if([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class ]]){
        return NO;
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

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    DLog(@"%s numbers of count %d",__PRETTY_FUNCTION__ ,[quotes count]);
    return [quotes count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    //this also affects the appearance of circular-type carousels
    return [quotes count] < NUMBER_OF_VISIBLE_ITEMS ? [quotes count] : NUMBER_OF_VISIBLE_ITEMS;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIImageView *imageView = nil;
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[QuoteView alloc] initWithFrame:CGRectMake(QUOTEVIEW_FRAME_X, QUOTEVIEW_FRAME_Y, 
                                                           QUOTEVIEW_FRAME_WIDTH,QUOTEVIEW_FRAME_HEIGHT)];
        view.alpha = 0.95;
        float shadowSize = 50.0f;
        view.layer.shadowColor = [[UIColor blackColor] CGColor];
        view.layer.shadowOffset = CGSizeMake(shadowSize,shadowSize);
        view.layer.shadowOpacity = 1.0f;
        view.layer.shadowRadius = shadowSize;
        view.layer.shouldRasterize = YES;  
    }
    else
    {
        for (id obj in [view subviews]) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                //
                DLog(@"image view");
                imageView = obj;
            }else if([obj isKindOfClass:[UILabel class]]){
                DLog(@"label class");
                label = obj;
            }
        }
    }
    
    QuoteView  *quoteView = (QuoteView*)view;
    NSUInteger randIndex = index%6;  //
    NSString *fileName = [NSString stringWithFormat:@"steve%d.jpg",randIndex];
    DLog(@"filename %@",fileName);
    quoteView.peopleImage = [UIImage imageNamed:fileName];
    
    QuoteObject *quote = (QuoteObject*)[self.quotes objectAtIndex:index%([quotes count])];
    if (!label) {
        quoteView.quoteText = quote.quoteText;
    }else {
        label.text = quote.quoteText;
        //imageView.image = [UIImage imageNamed:fileName];
    }
    
    //DLog(@"%s index %d  \n %@",__PRETTY_FUNCTION__ , index , quoteView.quoteText);

	return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	//note: placeholder views are only displayed on some carousels if wrapping is disabled
	return INCLUDE_PLACEHOLDERS? 2: 0;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    return nil;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return QUOTEVIEW_FRAME_WIDTH;
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
    
    QuoteObject *currentQuote =  [self.quotes objectAtIndex:index % [self.quotes count]];
    _currentQuoteText = [currentQuote quoteText];
    
    UIView  *cellView =  [carousel currentItemView];//[carousel itemViewAtIndex:index];
    __block UIImage *cellImage = nil;
    dispatch_queue_t capture_queue = dispatch_queue_create("capture", NULL);
    dispatch_async(capture_queue, ^{
        [self captureCurrentQuote:index carousel:carousel asImage:&cellImage];
        
    });
    
    NSString *idxString = [NSString stringWithFormat:@"%d / %d", index , [quotes count]];

    ShareViewController *_shareVC = [[ShareViewController alloc] initWithFrame:cellView.frame 
                                                                     quoteText:_currentQuoteText 
                                                                    quoteImage:cellImage 
                                                                   indexString:idxString];
    
//    
//    _shareVC.quoteText = _currentQuoteText;
//    _shareVC.quoteImage = cellImage;
//    _shareVC.indexString = idxString;

    _shareVC.quoteIndex = index;
    
    [UIView transitionFromView:cellView toView:_shareVC.view duration:.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
        if (finished) {
            //remove all gestures for carouse 
            [_quotesView setIgnoreAllGestures:YES];
            _isShowSocialView = YES;
            
            UIButton *backButton = (UIButton*)[_shareVC.view viewWithTag:1001];
            [backButton addEventHandler:^(id sender) {
                //flip back by tapping 
                [UIView transitionFromView:_shareVC.view toView:cellView duration:.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
                    //
                    [_quotesView setIgnoreAllGestures:NO];
                    _isShowSocialView = NO;
                }];
            } forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

//- (void)carouselCurrentItemIndexUpdated:(iCarousel *)carousel{
//    DLog(@"%s %d",__PRETTY_FUNCTION__ , [carousel currentItemIndex]);
//    
//    QuoteView *quoteView = (QuoteView*)carousel.currentItemView;
//    QuoteObject *quote = [quotes objectAtIndex:[carousel currentItemIndex]];
//    quoteView.quoteText = quote.quoteText;
//}
//

@end