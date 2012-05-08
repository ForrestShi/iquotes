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
    
}

- (void) loadQuotesFromPlistFile:(NSString*)plistFilePath;

@end

@implementation QuotesManager
@synthesize quotesArray = _quotesArray;

+ (QuotesManager*) shareInstance{
    static QuotesManager* _instance = nil;
    if (_instance == nil) {
        _instance = [[QuotesManager alloc] init];
        NSString *plist1Path = [[NSBundle mainBundle] pathForResource:@"jobs_quotes1" ofType:@"plist" ];
        [_instance loadQuotesFromPlistFile:plist1Path];
    }
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

//    dispatch_queue_t loadQueue = dispatch_queue_create("loadplist", NULL);
//    dispatch_async(loadQueue, ^{
//                       
//        NSDictionary    *dict = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
//        if (!dict) {
//            return ;
//        }
//        
//        NSArray *arrayObjects = [dict allValues];
//        for (id object in arrayObjects) {
//            QuoteObject *quote = [[QuoteObject alloc] init];
//            quote.quoteText = [object objectForKey:@"quote"];
//            if (_quotesArray == nil) {
//                _quotesArray = [NSMutableArray array];
//            }
//            [_quotesArray addObject:quote];
//        }
//        
//                   });
}

@end
