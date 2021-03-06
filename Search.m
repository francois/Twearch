//
//  Search.m
//  Twearch
//
//  Created by François Beausoleil on 2009-09-05.
//  Copyright 2009 Solutions Technologiques Internationales. All rights reserved.
//

#import "Search.h"
#import "Result.h"
#import "CJSONDeserializer.h"

@implementation Search

@synthesize query, querying, results;

NSURLConnection *connection;
NSMutableData *incomingData;

-(id)init {
  if (self = [super init]) {
    [self setQuery: @"enter Twitter query here"];
    [self setQuerying:NO];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [self setResults: arr];
    [arr release];
  }
  
  return self;
}

-(void) cleanupConnection {
  NSLog(@"Search#cleanupConnection");
  if (connection) {
    NSLog(@"Cleaning up connection");
    [connection release];
    connection = nil;
  }
  
  if (incomingData) {
    NSLog(@"Cleaning up incomingData");
    [incomingData release];
    incomingData = nil;
  }
  
  // We're done querying for now, so inform the view
  NSLog(@"#setQuerying:NO");
  [self setQuerying:NO];
}

-(void)dealloc {
  [self cleanupConnection];
  [self setResults:nil];
  [self setQuery:nil];
  [super dealloc];
}

-(NSURL *)queryUrl {
  NSMutableString *urlPath = [[NSMutableString alloc] initWithString:@"/search.json?"];
  if (lastSeenTweetId != 0) [urlPath appendFormat:@"since_id=%ud&", lastSeenTweetId];
  [urlPath appendFormat:@"q=%@", [self query]];

  NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:@"search.twitter.com" path:urlPath];
  [urlPath release];

  [url autorelease];
  NSLog(@"Twitter Query: %@", url);
  return url;
}

-(NSURLRequest *)queryRequest {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self queryUrl]];
  [request autorelease];
  return request;
}

-(void)refresh:(id) sender {
  // Abort if we're already in progress
  if ([self isQuerying]) return;

  [self cleanupConnection];
  [self setQuerying:YES];
  
  connection   = [[NSURLConnection alloc] initWithRequest:[self queryRequest] delegate:self];
}

-(void)cancel:(id)sender {
  if (connection) {
    // Docs say calling #cancel won't tell us anything anymore
    [connection cancel];

    [self cleanupConnection];
  }
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
  
  if (lastSeenTweet) {
    return [results count] - [results indexOfObject:lastSeenTweet];
  } else {
    // We couldn't find the last tweet, so let's say all results are new
    return [results count];
  }
}

// May be called multiple times, and if we are, we must trash previously received data and start anew
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  NSLog(@"connection:%@ didReceiveResponse:%@", connection, response);
  if (incomingData) [incomingData release];
  incomingData = [[NSMutableData alloc] init];
}

// Will be called once per buffer full
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  NSLog(@"connection:%@ didReceiveData:%ud", connection, [data length]);
  [incomingData appendData:data];
}

// The data is completely received only here, not before
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSLog(@"connectionDidFinishLoading:%@", connection);
  
  NSError *error;
  NSDictionary *json = [[CJSONDeserializer deserializer] deserializeAsDictionary:incomingData error:&error];
  if (json) {
    NSLog(@"Instantiating new results array");
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in [json objectForKey:@"results"]) {
      Result *result = [[Result alloc] initWithDictionary:dict];
      [arr addObject:result];
    }
    NSLog(@"Setting new results");
    [self setResults:arr];
    NSLog(@"arr retainCount: %d", [arr retainCount]);
    [arr release];
  } else {
    NSLog(@"Error parsing JSON returned from Twitter: %@", error);
  }

  [self cleanupConnection];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSLog(@"connection:%@ didFailWithError: %@", connection, error);
  [self cleanupConnection];
}

// To inform us of redirects
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
  return request;
}

@end
