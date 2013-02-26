//
//  AppDelegate.m
//  MFP
//
//  Created by Stefan Graupner on 26.02.13.
//  Copyright (c) 2013 meanderingsoul.com. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
  
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [_window makeKeyAndOrderFront:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
  [_window makeKeyAndOrderFront:self];
}

@end
