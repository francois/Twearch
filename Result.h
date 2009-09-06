//
//  Result.h
//  Twearch
//
//  Created by François Beausoleil on 2009-09-05.
//  Copyright 2009 Solutions Technologiques Internationales. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Result : NSObject {
  NSUInteger tweetId;
  NSURL *avatarURL;
  NSString *from, *message;
}

@property(readonly) NSUInteger tweetId;
@property(retain) NSURL *avatarURL;
@property(retain) NSString *from, *message;

-(id) initWithDictionary:(NSDictionary *)dict;

@end
