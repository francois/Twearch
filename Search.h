//
//  Search.h
//  Twearch
//
//  Created by François Beausoleil on 2009-09-05.
//  Copyright 2009 Solutions Technologiques Internationales. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Search : NSObject {
  NSString *query;
  BOOL querying;
  NSUInteger numberOfNewResults, numberOfResults, lastReadId, lastSeenTweetId;
  NSMutableArray *results;
}

@property(readwrite, copy) NSString *query;
@property(readwrite, getter=isQuerying) BOOL querying;
@property(readwrite, retain) NSArray *results;
@property(readonly) NSUInteger numberOfNewResults;

-(void)markAllRead:(id)sender;
-(void)refresh:(id)sender;

@end
