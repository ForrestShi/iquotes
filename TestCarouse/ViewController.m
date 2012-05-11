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

typedef enum{
    PEOPLE_VIEW,
    QUOTE_VIEW
} CAROUSELVIEW;

@interface ViewController() <iCarouselDataSource, iCarouselDelegate > {
@private
    CAROUSELVIEW _carouseView;
    ShareViewController *_shareVC ;
    NSString            *_currentQuoteText;
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


- (void)setUp
{
	//set up data
	wrap = YES;
	self.peoples = [NSMutableArray array];
	for (int i = 0; i < NUMBER_OF_ITEMS; i++)
	{
		[peoples addObject:[NSNumber numberWithInt:i]];
	}
    
    _carouseView = QUOTE_VIEW;
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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) swipAction:(UISwipeGestureRecognizer*)sender{
    
    [UIView animateWithDuration:1.0 animations:^{
        self.carousel.type = iCarouselTypeTimeMachine;
        self.carousel.vertical = NO;
        _carouseView = QUOTE_VIEW;
        self.carousel.alpha = 0.0;

    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.6 animations:^{
            [self.carousel reloadData];

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.6 animations:^{
                self.carousel.alpha = 1.0;
            } completion:^(BOOL finished) {                
            }];

        }];
        

    }];
        
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
        if (_carouseView == PEOPLE_VIEW) {
            view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"steve.png"]];
        }else if (_carouseView == QUOTE_VIEW) {
            view = [[QuoteView alloc] initWithFrame:CGRectMake(50, 80, 1024 - 50*2 , 768-160)];
        }
		label = [[UILabel alloc] initWithFrame:view.bounds];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [label.font fontWithSize:50];
		[view addSubview:label];
	}
	else
	{
		label = [[view subviews] lastObject];
	}
	
    //set label
    if (_carouseView == PEOPLE_VIEW ) {
       	label.text = [[peoples objectAtIndex:index] stringValue];
        
    }else if (_carouseView == QUOTE_VIEW ) {
        QuoteView  *quoteView = (QuoteView*)view;
        quoteView.backgroundColor = [UIColor blackColor];
        
        quoteView.peopleImage = [UIImage imageNamed:@"steve.png"];
        
        NSInteger quotesTotalNum = [quotes count];
        if (quotesTotalNum > 0 ) {
            QuoteObject *quote = (QuoteObject*)[self.quotes objectAtIndex:index%quotesTotalNum];
            quoteView.quoteText = quote.quoteText;
            DLog(@"%s count %d", __PRETTY_FUNCTION__, [quote.quoteText length] );
            if ([quote.quoteText length] > 60) {
                label.font = [label.font fontWithSize:30];
 
            }
        }
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
    return 600.0f + 50.0f; //ITEM_SPACING;
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

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    DLog(@"%s",__PRETTY_FUNCTION__);
    
    QuoteObject *currentQuote =  [self.quotes objectAtIndex:index % [self.quotes count]];
    _currentQuoteText = [currentQuote quoteText];
    
    UIView  *cellView = [carousel itemViewAtIndex:index];
    
//    _shareVC = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
//    UIView  *shareView  = _shareVC.view;
//    shareView.frame = cellView.frame;

    DLog(@"current quote %@", _currentQuoteText);
    _shareVC = [[ShareViewController alloc] initWithFrame:cellView.frame quoteText:_currentQuoteText];
    UIView  *shareView  = _shareVC.view;

    [UIView transitionFromView:cellView toView:shareView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
        if (finished) {
            //remove all gestures for carouse 
            [self.carousel setIgnoreAllGestures:YES];
            
            UIButton *backButton = (UIButton*)[shareView viewWithTag:1001];
            [backButton addEventHandler:^(id sender) {
                //flip back by tapping 
                [UIView transitionFromView:shareView toView:cellView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
                    //
                    [self.carousel setIgnoreAllGestures:NO];
                    
                }];
            } forControlEvents:UIControlEventTouchUpInside];

        }
    }];
}
 
@end