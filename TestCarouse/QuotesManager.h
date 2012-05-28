//
//  PListManager.h
//  QuotesApp
//
//  Created by Shi Forrest on 12-4-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuotesManager : NSObject

+ (QuotesManager*) shareInstance;

@property (nonatomic,strong) NSMutableArray*   quotesArray;

- (BOOL) bookmarkQuote:(NSUInteger)quoteIndex;
- (BOOL) isBookmarked:(NSUInteger)quoteIndex;
- (NSString*) todayQuote;

- (NSArray*) bookmarkQuotes;

@end
