//
//  AppDelegate.m
//  MFP
//
//  Created by Stefan Graupner on 26.02.13.
//  Copyright (c) 2013 meanderingsoul.com. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemLoader.h"

@interface AppDelegate ()
{
  ItemLoader *_loader;
}
@end

@implementation AppDelegate

+ (void)initialize
{
  [[NSUserDefaults standardUserDefaults] registerDefaults:
   [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithBool:NO], MFPBeginPlayingOnApplicationStartKey,
    nil, MFPLastFeedUpdateKey,
    nil]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [_window makeKeyAndOrderFront:self];
  _loader = [[ItemLoader alloc] init];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
  [_window makeKeyAndOrderFront:self];
}

@end
