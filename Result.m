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
  if (self = [super init]) {
    tweetId =   [[dict objectForKey:@"id"] unsignedIntegerValue];
    
    [self setAvatarURL: [[NSURL alloc] initWithString: [dict objectForKey:@"profile_image_url"]]];
    [self setFrom:      [dict objectForKey:@"from_user"]];
    [self setMessage:   [dict objectForKey:@"text"]];
  }
  
  return self;
}

-(void)dealloc {
  [self setAvatarURL: nil];
  [self setFrom: nil];
  [self setMessage: nil];
  [super dealloc];
}

@end
