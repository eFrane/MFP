//
//  MFPPlayback.m
//  MFP
//
//  Created by Stefan Graupner on 26.02.13.
//  Copyright (c) 2013 meanderingsoul.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "NSFileManager+DirectoryLocations.h"

#import "MFPPlayback.h"

@interface MFPPlayback () <AVAudioPlayerDelegate>
{
  NSArray    *_available;
  BOOL        _delayedPlaybackBegin;
  NSUInteger  _currentIdx;
  
  AVAudioPlayer *_player;
  AVAsset       *_asset;
}

- (void)reload:(NSNotification *)aNotification;
- (void)load;
- (void)playNext;

@end

@implementation MFPPlayback

- (id)init
{
  self = [super init];
  if (self)
  {
    srandom((unsigned int)time(NULL));
    
    [self load];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reload:)
                                                 name:MFPNewTitleAvailableNotification object:nil];
  }
  return self;
}

- (void)changePlayState:(id)sender
{
  if ([_available count] == 0 && !_delayedPlaybackBegin)
  {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Unfortunately, there is not yet anything playable available. You may still lean back though, because playback will begin automatically."
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert runModal];
    _delayedPlaybackBegin = YES;
    return;
  }
  
  [self setCurrentlyPlaying:!_currentlyPlaying];
  
  [_playStateMenuItem setTitle:(_currentlyPlaying) ? @"Pause" : @"Play"];
  
  [_playbackWindow setTitle:(_currentlyPlaying) ? @"Playing" : @"Paused"];
  [_playbackCoverView setCurrentlyPlaying:_currentlyPlaying];
  
  if (!_currentlyPlaying)
  {
    [self setTitle:nil];
    if (_player) [_player pause];
  } else
  {
    if (!_player) [self playNext];
    if (_asset)
    {
      NSArray *titleArray = [AVMetadataItem metadataItemsFromArray:[_asset metadataForFormat:@"org.id3"] withKey:AVMetadataID3MetadataKeyTitleDescription keySpace:@"org.id3"];
      [self setTitle:[[titleArray objectAtIndex:0] value]];
    }
  }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
  [self playNext];
}

- (void)playNext
{
  NSUInteger idx;
  
  while (idx == _currentIdx)
    idx = (NSUInteger)(random() % [_available count]);
  
  NSError *error = nil;
  
  NSURL *audioURL = [NSURL fileURLWithPath:[_available objectAtIndex:idx]];
  _player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
  if (error)
  {
    [[NSAlert alertWithError:error] runModal];
  }
  
  [_player setDelegate:self];
  @try
  {
    [_player prepareToPlay];
    [_player play];
    
    _asset = [AVAsset assetWithURL:audioURL];
  }
  @catch (NSException *exception)
  {
    NSLog(@"Something went wrong while loading audio file.");
  }
}

- (void)awakeFromNib
{
  if ([[NSUserDefaults standardUserDefaults] boolForKey:MFPBeginPlayingOnApplicationStartKey])
    [self changePlayState:self];
}

- (void)load
{
  NSString *availableFilename = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"available.txt"];
  NSString *available = [NSString stringWithContentsOfFile:availableFilename encoding:NSUTF8StringEncoding error:NULL];
  
  _available = [available componentsSeparatedByString:@"\n"];
  
  if (_delayedPlaybackBegin) [self changePlayState:self];
}

- (void)reload:(NSNotification *)aNotification
{
  [self load];
}

@end
