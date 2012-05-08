//
//  QuoteView.m
//  Cascade
//
//  Created by Shi Forrest on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuoteView.h"
#define GAP_BELOW_IMAGE 30.0f

#define QUOTE_TEXT_START_X 20.0
#define QUOTE_TEXT_START_Y 10.0 


@implementation QuoteView
@synthesize peopleImage = _peopleImage;
@synthesize quoteText = _quoteText;


- (void) baseInit{
    
    UIImageView *peopleImageView = nil; 
    if (_peopleImage) {
        peopleImageView = [[UIImageView alloc] initWithImage:_peopleImage];
    }
    //frame of image
    peopleImageView.center = CGPointMake(_peopleImage.size.width/2, _peopleImage.size.height/2);
    peopleImageView.alpha = 0.7;
    
    CGRect txtRect =  CGRectMake(_peopleImage.size.width + QUOTE_TEXT_START_X, QUOTE_TEXT_START_Y , 
                                 self.bounds.size.width - QUOTE_TEXT_START_X *2 - _peopleImage.size.width , 
                                 self.bounds.size.height - QUOTE_TEXT_START_Y*2) ;


    UILabel *quoteLabel = [[UILabel alloc] initWithFrame:txtRect];
    //frame
    
    quoteLabel.textAlignment = UITextAlignmentRight;
    
    quoteLabel.text = _quoteText;
    quoteLabel.font = [UIFont fontWithName:@"ArialMT" size:34];
    quoteLabel.textColor = [UIColor whiteColor];
   // quoteLabel.shadowColor = [UIColor lightGrayColor];
    quoteLabel.lineBreakMode = UILineBreakModeWordWrap;
    quoteLabel.numberOfLines = 0;

   // quoteLabel.transform = CGAffineTransformMakeRotation(M_PI/6);
    quoteLabel.backgroundColor = [UIColor clearColor];
    quoteLabel.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:peopleImageView];
    [self addSubview:quoteLabel];
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void) layoutSubviews{
    [self baseInit];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}

@end
