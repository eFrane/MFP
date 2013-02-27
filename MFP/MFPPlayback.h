//
//  MFPPlayback.h
//  MFP
//
//  Created by Stefan Graupner on 26.02.13.
//  Copyright (c) 2013 meanderingsoul.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MFPPlaybackCoverView.h"

@interface MFPPlayback : NSObject

@property (readwrite, assign) IBOutlet NSMenuItem *playStateMenuItem;

@property (readwrite, assign) IBOutlet NSWindow             *playbackWindow;
@property (readwrite, assign) IBOutlet MFPPlaybackCoverView *playbackCoverView;

@property (readwrite) NSString *title;
@property (readwrite) BOOL      currentlyPlaying;

- (IBAction)changePlayState:(id)sender;

@end
