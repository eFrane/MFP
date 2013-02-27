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
    NSAlert *alert = [NSAlert alertWithMessageText:@"Unfortunately, there is not yet anything playable available."
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"You may still lean back though, because playback will begin automatically."];
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
    [_currentTitleMenuItem setTitle:@"Paused"];
    if (_player) [_player pause];
  } else
  {
    if (!_player) [self playNext];
    if (_asset)
    {
      NSArray *titleArray = [AVMetadataItem metadataItemsFromArray:[_asset metadataForFormat:@"org.id3"] withKey:AVMetadataID3MetadataKeyTitleDescription keySpace:@"org.id3"];
      
      NSString *title = [[titleArray objectAtIndex:0] value];
      [self setTitle:title];
      [_currentTitleMenuItem setTitle:title];
    }
  }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
  [self performSelector:@selector(playNext) withObject:nil afterDelay:0.5];
}

- (void)playNext
{
  NSUInteger idx;
  
  if ([_available count] > 1)
  {
    while (idx == _currentIdx)
      idx = (NSUInteger)(random() % [_available count]);
  } else
  {
    idx = 0;
  }
  _currentIdx = idx;
  
  NSError *error = nil;
  
  NSURL *audioURL = [NSURL fileURLWithPath:[_available objectAtIndex:idx]];
  if (!audioURL)
  {
    NSLog(@"Something went wrong while loading %@", [_available objectAtIndex:idx]);
    return;
  }
  
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
  
  NSMutableArray *availableArray = [NSMutableArray arrayWithArray:[available componentsSeparatedByString:@"\n"]];
  [availableArray removeLastObject];
  
  _available = availableArray;
  
  if (_delayedPlaybackBegin)
    [self performSelector:@selector(changePlayState:) withObject:self afterDelay:2.0];
}

- (void)reload:(NSNotification *)aNotification
{
  [self load];
}

@end
