//
//  PListManager.m
//  QuotesApp
//
//  Created by Shi Forrest on 12-4-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuotesManager.h"
#import "QuoteObject.h"

@interface QuotesManager () {
@private
    NSMutableArray  *_quotesArray;
    NSMutableArray  *_favoriteQuotesArray;
}

- (void) loadQuotesFromPlistFile:(NSString*)plistFilePath;

@end

@implementation QuotesManager
@synthesize quotesArray = _quotesArray;

+ (QuotesManager*) shareInstance{
    static QuotesManager* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[QuotesManager alloc] init];
            NSString *plist1Path = [[NSBundle mainBundle] pathForResource:@"jobs_quotes1" ofType:@"plist" ];
            [_instance loadQuotesFromPlistFile:plist1Path];
        }
    });
    return _instance;
}

- (id) initWithPlist:(NSString*)plistFilePath {
    if (self = [super init]) {
        [self loadQuotesFromPlistFile:plistFilePath];
    }
    return self;
}
- (void) loadQuotesFromPlistFile:(NSString*)plistFilePath{
    if (!plistFilePath) {
        return;
    }
    
    NSDictionary    *dict = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    if (!dict) {
        return ;
    }
    
    NSArray *arrayObjects = [dict allValues];
    for (id object in arrayObjects) {
        QuoteObject *quote = [[QuoteObject alloc] init];
        quote.quoteText = [object objectForKey:@"quote"];
        if (_quotesArray == nil) {
            _quotesArray = [NSMutableArray array];
        }
        [_quotesArray addObject:quote];
    }
}

#pragma mark - Bookmark Quotes

- (void) bookmarkQuote:(NSUInteger)quoteIndex{
    QuoteObject *likedQuote = [self.quotesArray objectAtIndex:quoteIndex];
    if (!_favoriteQuotesArray) {
        _favoriteQuotesArray = [[NSMutableArray alloc] init];
    }
    if (![_favoriteQuotesArray containsObject:likedQuote]) {
        DLog(@"%s add bookmarked quote",__PRETTY_FUNCTION__);
        [_favoriteQuotesArray addObject:likedQuote];
    }
}

- (NSArray*) bookmarkQuotes{
    DLog(@"%s count %d",__PRETTY_FUNCTION__ , [_favoriteQuotesArray count]);
    return _favoriteQuotesArray;
}

@end
