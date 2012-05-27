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


#define NUMBER_OF_VISIBLE_ITEMS (IS_IPAD? 20: 25)


#define INCLUDE_PLACEHOLDERS NO

#define QUOTEVIEW_FRAME_X (IS_IPAD ? 80.0f : 0.0f)
#define QUOTEVIEW_FRAME_Y (IS_IPAD ? 40.0f : 0.0f)

typedef enum{
    CATEGORY,
    QUOTE
} VIEWTYPE;

@interface ViewController() <iCarouselDataSource, iCarouselDelegate , UIGestureRecognizerDelegate , FlipBackDelegate > {
@private
    BOOL                _isShowSocialView;
    BOOL                _isBookmarkQuoteView;
    NSString            *_currentQuoteText;
    NSTimer             *changeBgTimer ;
    iCarousel           *_quotesView;
    CategoryViewController *_categoryVC;
    ShareViewController *_shareVC;
    
    UIImageView *bacgroundImageView;
}
@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSArray *quotes;
@end


@implementation ViewController
@synthesize wrap;
@synthesize quotes;



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (id) initWithFrame:(CGRect)frame{
    if ((self = [super init]))
    {
        self.view.frame = frame;
    }
    return self;
}

- (void) buildDynamicBackgroudImages{
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
    
    if (!bacgroundImageView) {
        bacgroundImageView = [[UIImageView alloc] initWithFrame:FULLFRAME];
        bacgroundImageView.contentMode =  UIViewContentModeScaleAspectFit;
        bacgroundImageView.image = [UIImage imageNamed:@"8.jpeg"];
    
    }
    
    changeBgTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 block:^(NSTimeInterval time) {
        NSString *imageName = [imageNameArray objectAtIndex:(count++)%[imageNameArray count] ];
        
        BOOL animated = YES;
        
        if (animated) {
            CATransition *transition = [CATransition animation];
            transition.duration = 2.5f;
            // WHY NO WORK ?
            transition.timingFunction = (rand()%2 == 0 ? [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] : [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]);
            transition.type = (rand()%2 == 0 ? kCATransitionFade : kCATransitionFromTop );
            transition.subtype = kCATransitionPush;
            [bacgroundImageView.layer addAnimation:transition forKey:@"image"];
        }
        
        bacgroundImageView.image = [UIImage imageNamed:imageName];
        
    } repeats:YES];
    
    [self.view addSubview:bacgroundImageView];

}

- (void) buildQuoteCarousel{
    // Quote View
    CGRect viewBounds = self.view.bounds;
    if (!_quotesView) {
        _quotesView = [[iCarousel alloc] initWithFrame:viewBounds];
        _quotesView.delegate = self;
        _quotesView.dataSource = self;
        _quotesView.backgroundColor = [UIColor clearColor];
        
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
    _quotesView.alpha = 0.0;
    [self.view addSubview:_quotesView];
    [UIView animateWithDuration:1.0 animations:^{
        _quotesView.alpha = 1.0;
    }];
    
    if (!_categoryVC) {
        _categoryVC = [[CategoryViewController alloc] initWithFrame:self.view.bounds];
    }
    _categoryVC.view.alpha = 0.0;
    [self.view addSubview:_categoryVC.view];
    
    // Swip action to LEFT 
    UISwipeGestureRecognizer *swipLeftGesture = [[UISwipeGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UISwipeGestureRecognizer *swip = (UISwipeGestureRecognizer*)sender;
        
        if (state == UIGestureRecognizerStateEnded) {
            NSLog(@"%d directi on %d", [NSThread isMainThread] , [swip direction]);
            
            __block CGPoint oldCenter = _quotesView.center;
            float newX = oldCenter.x - self.view.bounds.size.width*0.9;
            if (newX > - self.view.bounds.size.width*0.5 && newX < self.view.bounds.size.width * 0.1 ) {
                //come back to reader mode
                [_quotesView setIgnoreAllGestures:YES];
                [UIView animateWithDuration:1.0 animations:^{
                    _quotesView.alpha = 0.0;
                    _quotesView.center = CGPointMake(newX , oldCenter.y);

                } completion:^(BOOL finished) {
                }];

            }
             
        }
    }];
    swipLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipLeftGesture.numberOfTouchesRequired = 1;
    
    // SHOW CATEGORY VIEW 
    //SWIP to right 
    UISwipeGestureRecognizer *swipRightGesture = [[UISwipeGestureRecognizer alloc] initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UISwipeGestureRecognizer *swip = (UISwipeGestureRecognizer*)sender;
        
        if (state == UIGestureRecognizerStateEnded) {

            __block CGPoint oldCenter = _quotesView.center;
            float newX = oldCenter.x + self.view.bounds.size.width*0.9;

            if (newX < self.view.bounds.size.width + self.view.bounds.size.width/2 && newX > self.view.bounds.size.width) {
                [_quotesView setIgnoreAllGestures:YES];
                [UIView animateWithDuration:1.0 animations:^{
                    //
                    _quotesView.center = CGPointMake(newX , oldCenter.y); 
                    _quotesView.alpha = 0.0;

                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.5 animations:^{
                        _categoryVC.view.alpha = 1.0;
                        
                    }];
                }];
            }
            
            if (oldCenter.x < 0 && oldCenter.x >= - self.view.bounds.size.width * 0.5 ) {
                [_quotesView setIgnoreAllGestures:NO];
                [UIView animateWithDuration:1.0 animations:^{
                    //
                    _quotesView.center = CGPointMake(self.view.bounds.size.width*0.5 , oldCenter.y); 
                    _quotesView.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                }];

            }

        }
    }];
    swipRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    swipRightGesture.numberOfTouchesRequired = 1;
    
    swipLeftGesture.delegate = self;
    swipRightGesture.delegate = self;
    //Swip left/right to make carousel visible/invisible 
    [self.view addGestureRecognizer:swipLeftGesture];
    [self.view addGestureRecognizer:swipRightGesture];

}
- (void) buildAllQuotesView{
	// Do any additional setup after loading the view, typically from a nib.
    if (!quotes) {
        quotes = [[QuotesManager shareInstance] quotesArray];
    }
        
    [self buildQuoteCarousel];
    
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
                _isBookmarkQuoteView = NO;
                quotes = [[QuotesManager shareInstance] quotesArray];
                break;
            }   
            case 1:
            {
                _isBookmarkQuoteView = YES;
                quotes = [[QuotesManager shareInstance] bookmarkQuotes];
                break;
            }
            default:
                break;
        }
        
        _quotesView.dataSource = nil;
        _quotesView.dataSource = self;

        
        _quotesView.alpha = 1.0;
        [_quotesView setIgnoreAllGestures:NO];

        
        //transition of views
        __block CGPoint oldCenter = _quotesView.center;
        [UIView animateWithDuration:.5 animations:^{
            
           // _categoryVC.view.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0);
            _categoryVC.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:1.0 animations:^{
                
                float newX = oldCenter.x - self.view.bounds.size.width*0.9;
                if (newX > self.view.bounds.size.width/4) {
                    //come back to reader mode
                    _quotesView.center = CGPointMake(newX , oldCenter.y);
                }
                
            }];
            
        }];
        
    }];

}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildDynamicBackgroudImages];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self buildAllQuotesView];
    });
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
                                                           self.view.bounds.size.width - QUOTEVIEW_FRAME_X*2,
                                                           self.view.bounds.size.height - QUOTEVIEW_FRAME_Y*2)];
        view.alpha = 0.95;
        float shadowSize = 20.0f;
        view.layer.shadowColor = [[UIColor blackColor] CGColor];
        view.layer.shadowOffset = CGSizeMake(-shadowSize,shadowSize);
        view.layer.shadowOpacity = .8f;
        view.layer.shadowRadius = shadowSize/2;
        view.layer.shouldRasterize = YES;  
    }
    else
    {
        for (id obj in [view subviews]) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                //
                imageView = obj;
            }else if([obj isKindOfClass:[UILabel class]]){
                label = obj;
            }
        }
    }
    
    QuoteView  *quoteView = (QuoteView*)view;
    NSUInteger randIndex = index%6;  //
    NSString *fileName = [NSString stringWithFormat:@"steve%d.jpg",randIndex];
    quoteView.peopleImage = [UIImage imageNamed:fileName];
    
    QuoteObject *quote = (QuoteObject*)[self.quotes objectAtIndex:index%([quotes count])];
    if (!label) {
        quoteView.quoteText = quote.quoteText;
    }else {
        label.text = quote.quoteText;
        //imageView.image = [UIImage imageNamed:fileName];
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
    return nil;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return self.view.bounds.size.width - QUOTEVIEW_FRAME_X * 2;
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
    return YES;
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
    if (_isShowSocialView || [self.quotes count] == 0 ) {
        return;
    }
        
    QuoteObject *currentQuote =  [self.quotes objectAtIndex:index % [self.quotes count]];
    _currentQuoteText = [currentQuote quoteText];
    
    UIView  *cellView =  [carousel currentItemView];//[carousel itemViewAtIndex:index];
    __block UIImage *cellImage = nil;
    dispatch_queue_t capture_queue = dispatch_queue_create("capture", NULL);
    dispatch_async(capture_queue, ^{
        [self captureCurrentQuote:index carousel:carousel asImage:&cellImage];
        
    });
    
    NSString *idxString = [NSString stringWithFormat:@"%d/%d", index+1 , [quotes count] ];

    ShareViewController *shareViewController = [[ShareViewController alloc] initWithFrame:cellView.bounds 
                                                                     quoteText:_currentQuoteText 
                                                                    quoteImage:cellImage 
                                                                   indexString:idxString
                                                                         index:index
                                                                      bookmark:_isBookmarkQuoteView];
    
    shareViewController.delegate = self;
    
    _shareVC = shareViewController;
    
    
    [UIView transitionFromView:cellView toView:_shareVC.view duration:.5 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
        if (finished) {
            //remove all gestures for carouse 
            [_quotesView setIgnoreAllGestures:YES];
            _isShowSocialView = YES;
            
            [_shareVC.view bringSubviewToFront:_quotesView];
        }
    }];
}

- (void) flipBack{
    //flip back by tapping 
    [UIView transitionFromView:_shareVC.view toView:[_quotesView currentItemView] duration:.5 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
        //
        [_quotesView setIgnoreAllGestures:NO];
        _isShowSocialView = NO;
    }];
    
}
#pragma mark - Shake Motion

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:nil];
    }
}



@end