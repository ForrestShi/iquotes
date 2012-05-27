//
//  QuoteView.m
//  Cascade
//
//  Created by Shi Forrest on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuoteView.h"
#define GAP_BELOW_IMAGE 30.0f

#define QUOTE_TEXT_START_X ( IS_IPAD ? 20.0 : 0.0 )
#define QUOTE_TEXT_START_Y ( IS_IPAD ? 10.0 : 0.0 )



@implementation QuoteView
@synthesize peopleImage = _peopleImage;
@synthesize quoteText = _quoteText;


- (void) baseInit{
    
    UIImageView *peopleImageView = nil; 
    if (_peopleImage) {
        peopleImageView = [[UIImageView alloc] initWithImage:_peopleImage];
        peopleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    //frame of image
    peopleImageView.center = CGPointMake(_peopleImage.size.width/2, _peopleImage.size.height/2 + QUOTE_TEXT_START_Y*2);
    peopleImageView.alpha = 0.7;
    peopleImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UITextAlignment quoteAlignmentStyle = UITextAlignmentRight;
    // frame 1 : image left + text right 
    CGRect txtRect =  CGRectMake(_peopleImage.size.width + QUOTE_TEXT_START_X, QUOTE_TEXT_START_Y , 
                                 self.bounds.size.width - QUOTE_TEXT_START_X *2 - _peopleImage.size.width , 
                                 self.bounds.size.height - QUOTE_TEXT_START_Y*2) ;


    if (_peopleImage.size.width > self.bounds.size.width/2 ) {
        //too large image
        txtRect = CGRectMake(QUOTE_TEXT_START_X, QUOTE_TEXT_START_Y, 
                             self.bounds.size.width - QUOTE_TEXT_START_X*2, 
                             self.bounds.size.height - QUOTE_TEXT_START_Y*2);
        quoteAlignmentStyle = UITextAlignmentCenter;
    }
    
    UILabel *quoteLabel = [[UILabel alloc] initWithFrame:txtRect];
    //frame
    quoteLabel.textAlignment = quoteAlignmentStyle;

    quoteLabel.text = _quoteText;
    int fontSize = FONT_SIZE_BIG;
    if ([_quoteText length] > 250 ) {
        fontSize = FONT_SIZE_MIDDLE;
    } 
    quoteLabel.font = [UIFont fontWithName:@"Chalkduster" size:fontSize];
    
    quoteLabel.textColor = [UIColor whiteColor];
    quoteLabel.lineBreakMode = UILineBreakModeWordWrap;
    quoteLabel.numberOfLines = 0;

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
