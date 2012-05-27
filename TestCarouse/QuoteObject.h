//
//  QuoteObject.h
//  QuotesApp
//
//  Created by Shi Forrest on 12-4-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuoteObject : NSObject <NSCoding>

@property (nonatomic,strong) NSString*  quoteText;
@property (nonatomic)        NSUInteger quoteIndex;
@property (nonatomic)        BOOL       bookmark;

@end
