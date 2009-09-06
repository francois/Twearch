//
//  Result.m
//  Twearch
//
//  Created by François Beausoleil on 2009-09-05.
//  Copyright 2009 Solutions Technologiques Internationales. All rights reserved.
//

#import "Result.h"


@implementation Result

@synthesize tweetId;
@synthesize avatarURL;
@synthesize from;
@synthesize message;

-(id) initWithDictionary:(NSDictionary *)dict {
  NSLog(@"%@", dict);
  if (self = [super init]) {
    tweetId = [[dict objectForKey:@"id"] unsignedIntegerValue];
    avatarURL = [dict objectForKey:@"profile_image_url"];
    from = [dict objectForKey:@"from_user"];
    message = [dict objectForKey:@"text"];
  }
  
  return self;
}

@end
