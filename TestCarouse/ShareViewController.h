//
//  ShareViewController.h
//  iquotes
//
//  Created by Shi Forrest on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipBackDelegate <NSObject>

- (void) flipBack;

@end

@interface ShareViewController : UIViewController {

}

@property (nonatomic) id<FlipBackDelegate>    delegate;

- (id) initWithFrame:(CGRect)frame 
           quoteText:(NSString*)quote 
          quoteImage:(UIImage*)image 
         indexString:(NSString*)idx
               index:(NSUInteger)index
            bookmark:(BOOL)yesOrNo;

@end
