//
//  SearchesController.h
//  Twearch
//
//  Created by François Beausoleil on 2009-09-06.
//  Copyright 2009 Solutions Technologiques Internationales. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchesController : NSObject {
  IBOutlet NSTableView *table;
  IBOutlet NSArrayController *controller;
}

-(void)add:(id)sender;
-(void)remove:(id)sender;
-(void)refresh:(id)sender;

@end
