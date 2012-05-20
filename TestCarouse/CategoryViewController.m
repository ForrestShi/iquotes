//
//  CategoryViewController.m
//  iquotes
//
//  Created by Shi Forrest on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"
#import "iCarousel.h"

@interface CategoryViewController ()<iCarouselDataSource, iCarouselDelegate >
{
    iCarousel           *_categoryView;
}

@end

@implementation CategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //Category view
    CGRect viewBounds = self.view.bounds;
    
    if (!_categoryView) {
        
        _categoryView = [[iCarousel alloc] initWithFrame:viewBounds];
        _categoryView.type = iCarouselTypeWheel;
        _categoryView.delegate = self;
        _categoryView.dataSource = self;  
        
        _categoryView.decelerationRate = 2.5;
        _categoryView.vertical = NO;
        
    }
    _categoryView.alpha = 1.0;
    [self.view addSubview:_categoryView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"steve5.png"]];
        
        nameLabel = [[UILabel alloc] initWithFrame:view.bounds];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = UITextAlignmentCenter;
        
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
    return 500;
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
