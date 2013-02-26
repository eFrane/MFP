//
//  MFPPlayback.h
//  MFP
//
//  Created by Stefan Graupner on 26.02.13.
//  Copyright (c) 2013 meanderingsoul.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFPPlayback : NSObject

@property (readwrite) NSString *title;
@property (readwrite) BOOL      currentlyPlaying;

@end
