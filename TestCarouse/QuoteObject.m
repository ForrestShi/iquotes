//
//  QuoteObject.m
//  QuotesApp
//
//  Created by Shi Forrest on 12-4-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuoteObject.h"

#define kEncodeKeyStringValue   @"kEncodeKeyStringValue" 
#define kEncodeKeyIntValue      @"kEncodeKeyIntValue" 
#define kEncodeKeyBOOLValue     @"kEncodeKeyBOOLValue" 

@implementation QuoteObject

@synthesize quoteText, quoteIndex, bookmark;

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.quoteText = [aDecoder decodeObjectForKey:kEncodeKeyStringValue];
        self.quoteIndex = [[aDecoder decodeObjectForKey:kEncodeKeyIntValue] intValue];
        self.bookmark = [[aDecoder decodeObjectForKey:kEncodeKeyBOOLValue] boolValue];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder{

    if (aCoder) {
        [aCoder encodeObject:self.quoteText forKey:kEncodeKeyStringValue];
        [aCoder encodeObject:[NSNumber numberWithInt: self.quoteIndex] forKey:kEncodeKeyIntValue];
        [aCoder encodeObject:[NSNumber numberWithInt: self.bookmark] forKey:kEncodeKeyBOOLValue];
    }
}

@end
