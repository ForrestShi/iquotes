//
//  CategoryViewController.m
//  iquotes
//
//  Created by Shi Forrest on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"
#import "iCarousel.h"
#import <QuartzCore/QuartzCore.h>

@interface CategoryViewController ()<iCarouselDataSource, iCarouselDelegate >
{
    iCarousel           *_categoryView;
}

@end

@implementation CategoryViewController


- (id) initWithFrame:(CGRect)frame{
    if (self = [super init]) {
        self.view.frame = frame;
    }
    return self;
}

- (void) buildUp{
    //Category view
    CGRect viewBounds = self.view.bounds;
    
    if (!_categoryView) {
        
        _categoryView = [[iCarousel alloc] initWithFrame:viewBounds];
        _categoryView.type = iCarouselTypeLinear;
        _categoryView.delegate = self;
        _categoryView.dataSource = self;  
        
        _categoryView.decelerationRate = 2.5;
        _categoryView.vertical = NO;
        _categoryView.backgroundColor = [UIColor clearColor];
        
    }
    _categoryView.alpha = 1.0;
    [self.view addSubview:_categoryView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self buildUp];
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 3;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    //this also affects the appearance of circular-type carousels
    return 3;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *nameLabel = nil;
    if (!view) {
        view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page.png"]];
        
        nameLabel = [[UILabel alloc] initWithFrame:view.bounds];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:30];
        nameLabel.layer.shadowColor = [UIColor grayColor].CGColor;
        nameLabel.layer.shadowOffset = CGSizeMake(-8, 8);
        nameLabel.layer.shadowOpacity = 0.7;
        nameLabel.layer.shadowRadius = 3;
        

        [view addSubview:nameLabel];
    }
    
    switch (index) {
        case 0:
            nameLabel.text = @"All Quotes";
            break;
        case 1:
            nameLabel.text = @"My Favorites";
            break;
        case 2:
            nameLabel.text = @"About Steve";
            break;

        default:
            break;
    }
	return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	//note: placeholder views are only displayed on some carousels if wrapping is disabled
	return  0;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    return nil;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return 300;
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
    return NO;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    DLog(@"%s index %d ",__PRETTY_FUNCTION__ , index);
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"select_category" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:@"category_index"]]];
}


@end
