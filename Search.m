//
//  Search.m
//  Twearch
//
//  Created by François Beausoleil on 2009-09-05.
//  Copyright 2009 Solutions Technologiques Internationales. All rights reserved.
//

#import "Search.h"
#import "Result.h"


@implementation Search

@synthesize query, querying, results;

-(id)init {
  if (self = [super init]) {
    [self setQuery: @""];
    [self setQuerying:NO];
    [self setResults: [[NSMutableArray alloc] init]];
  }
  
  return self;
}

-(void)dealloc {
  [super dealloc];
}

-(void)search:(id) sender {
}

-(void)markAllRead:(id)sender {
  Result * result = [results lastObject];
  
  // KVO compliance: this will change the numberOfNewResults, since it will set it to 0
  [self willChangeValueForKey:@"numberOfNewResults"];
  lastSeenTweetId = [result tweetId];
  [self didChangeValueForKey:@"numberOfNewResults"];
}

// Calculate the number of new results
-(NSUInteger)numberOfNewResults {
  // Shortcut: if we've never read anything, then we know all the results are new
  if (lastSeenTweetId == 0) return [results count];
  
  Result *lastSeenTweet = nil;
  for (Result *result in results) {
    if ([result tweetId] == lastSeenTweetId) {
      lastSeenTweet = result;
      break;
    }
  }
  
  return [results count] - [results indexOfObject:lastSeenTweet];
}

@end
