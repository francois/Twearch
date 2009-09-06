//
//  Search.m
//  Twearch
//
//  Created by François Beausoleil on 2009-09-05.
//  Copyright 2009 Solutions Technologiques Internationales. All rights reserved.
//

#import "Search.h"
#import "Result.h"
#import "JSON/JSON.h"

@implementation Search

@synthesize query, querying, results;

NSURLConnection *connection;
NSMutableData *incomingData;

-(id)init {
  if (self = [super init]) {
    [self setQuery: @"enter Twitter query here"];
    [self setQuerying:NO];
    [self setResults: [[NSMutableArray alloc] init]];
  }
  
  return self;
}

-(void)dealloc {
  [super dealloc];
}

-(NSURL *)queryUrl {
  NSMutableString *urlPath = [[NSMutableString alloc] initWithString:@"/search.json?"];
  if (lastSeenTweetId != 0) [urlPath appendFormat:@"since_id=%ud&", lastSeenTweetId];
  [urlPath appendFormat:@"q=%@", [self query]];

  NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:@"search.twitter.com" path:urlPath];
  [urlPath dealloc], urlPath = nil;

  [url autorelease];
  NSLog(@"Twitter Query: %@", url);
  return url;
}

-(NSURLRequest *)queryRequest {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self queryUrl]];
  [request autorelease];
  return request;
}

-(void) cleanupConnection {
  if (connection) {
    [connection release];
    connection = nil;
  }
  
  if (incomingData) {
    [incomingData release];
    incomingData = nil;
  }
}

-(void)refresh:(id) sender {
  // Abort if we're already in progress
  if ([self isQuerying]) return;

  [self cleanupConnection];
  
  connection   = [[NSURLConnection alloc] initWithRequest:[self queryRequest] delegate:self];
}

-(void)cancel:(id)sender {
  if (connection) {
    // Docs say calling #cancel won't tell us anything anymore
    [connection cancel];

    [self cleanupConnection];

    // We're done querying for now, so inform the view
    [self setQuerying:NO];
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
  
  return [results count] - [results indexOfObject:lastSeenTweet];
}

// May be called multiple times, and if we are, we must trash previously received data and start anew
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  NSLog(@"connection:%@ didReceiveResponse:%@", connection, response);
  if (incomingData) [incomingData dealloc];
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
  NSString *jsonSource = [[NSString alloc] initWithData:incomingData encoding:NSUTF8StringEncoding];
  NSDictionary *json = [jsonSource JSONValue];
  NSLog(jsonSource);
  [jsonSource dealloc], jsonSource = nil;

  NSArray *arr = [json objectForKey:@"results"];
  for (NSDictionary *dict in arr) {
    NSLog(@"result: %@", dict);
  }

  [arr dealloc], arr = nil;
  [json dealloc], json = nil;
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
