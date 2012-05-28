//
//  PListManager.m
//  QuotesApp
//
//  Created by Shi Forrest on 12-4-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuotesManager.h"
#import "QuoteObject.h"

#define LOAD_ARCHIVED_DATA 1
#define ARCHIVED_DATA_FILE_NAME @"archived_quotes"

@interface QuotesManager () {
@private
    NSMutableArray  *_quotesArray;
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
            DLog(@"%s",__PRETTY_FUNCTION__);
            _instance = [[QuotesManager alloc] init];
            
            if ([_instance canLoadFromArchivedData]) {
                [_instance loadFromArchivedData];
            }else {
                [_instance loadQuotesFromPlistFile];
            }   
            
        [[NSNotificationCenter defaultCenter] addObserverForName:@"save_when_leave" object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
            //archive datat (include bookmark)
            DLog(@"%s",__PRETTY_FUNCTION__);
            [_instance archiveQuoteData];
            //save current index 
            
            //[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currentIndex] forKey:@"current"];
            
            
        }];
        }
    });
    return _instance;
}

- (NSString*) todayQuote{
    
    int randIndex = rand() % [self.quotesArray count] ;
    QuoteObject *randObj = [self.quotesArray objectAtIndex:randIndex];
    return randObj.quoteText;
}

#pragma mark - Privates 

- (NSString*) archivedDataPath{
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[docPath objectAtIndex:0], ARCHIVED_DATA_FILE_NAME];
    return filePath;
}

- (BOOL) canLoadFromArchivedData{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self archivedDataPath]]; 
}

- (void) loadFromArchivedData{
    
    NSData *archivedData = [NSData dataWithContentsOfFile:[self archivedDataPath]];
    _quotesArray = (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
}

- (void) archiveQuoteData{
    NSData *plistData = [NSKeyedArchiver archivedDataWithRootObject:_quotesArray];
    if (NO == [plistData writeToFile:[self archivedDataPath] atomically:YES]) {
        DLog(@"Failed to save");
    }

}

- (void) loadQuotesFromPlistFile{
    
    NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"jobs_quotes1" ofType:@"plist" ];

    if (!plistFilePath) {
        return;
    }
    
    NSDictionary    *dict = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    if (!dict) {
        return ;
    }
    
    NSArray *arrayObjects = [dict allValues];
    int i=0;
    for (id object in arrayObjects) {
        QuoteObject *quote = [[QuoteObject alloc] init];
        quote.quoteIndex = i++;
        quote.quoteText = [object objectForKey:@"quote"];
        quote.bookmark = NO;
        if (_quotesArray == nil) {
            _quotesArray = [NSMutableArray array];
        }
        [_quotesArray addObject:quote];
    }
    
    //create a new plist file 
    [self archiveQuoteData];
}



#pragma mark - Bookmark Quotes

- (BOOL) bookmarkQuote:(NSUInteger)quoteIndex{
    DLog(@"%s index %d",__PRETTY_FUNCTION__ , quoteIndex);

    QuoteObject *likedQuote = [self.quotesArray objectAtIndex:quoteIndex];
    if (likedQuote) {
        likedQuote.bookmark = !likedQuote.bookmark;
    }
    return likedQuote.bookmark;
}

- (BOOL) isBookmarked:(NSUInteger)quoteIndex{
    QuoteObject *likedQuote = [self.quotesArray objectAtIndex:quoteIndex];
    return likedQuote.bookmark;
}

- (NSArray*) bookmarkQuotes{    
    NSPredicate *bookmarkPredict = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"bookmark == 1"]];
    NSArray *favorites = [_quotesArray filteredArrayUsingPredicate:bookmarkPredict];
    DLog(@"favorites %@",favorites);
    return favorites;
}

@end
