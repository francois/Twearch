//
//  SearchesController.m
//  Twearch
//
//  Created by François Beausoleil on 2009-09-06.
//  Copyright 2009 Solutions Technologiques Internationales. All rights reserved.
//

#import "SearchesController.h"
#import "Search.h"

@implementation SearchesController

-(void)add:(id)sender {
  [controller addObject:[[Search alloc] init]];
  [table editColumn: 0
                row: ([[controller arrangedObjects] count] - 1)
          withEvent:nil
             select:YES];
}

-(void)remove:(id)sender {
  [controller remove:sender];
}

@end
