//
//  ItemLoader.m
//  MFP
//
//  Created by Stefan Graupner on 26.02.13.
//  Copyright (c) 2013 meanderingsoul.com. All rights reserved.
//

#import <PubSub/PubSub.h>

#import "ItemLoader.h"

@interface ItemLoader () <NSURLDownloadDelegate>

@property (readwrite) PSFeed *feed;
@property (readwrite) NSMutableArray *queue;

- (void)refreshing:(NSNotification *)aNotification;
- (void)downloadNext;

@end

@implementation ItemLoader

- (id)init
{
  self = [super init];
  if (self)
  {
    PSClient *client = [PSClient applicationClient];
    
    _feed = [client addFeedWithURL:[NSURL URLWithString:kMFPFeedURL]];

    PSFeedSettings *s = [_feed settings];
    
    [s setRefreshInterval:86400];
    
    [_feed setSettings:s];
    
    NSDate *lastRetrieval = [[NSUserDefaults standardUserDefaults] objectForKey:MFPLastFeedUpdateKey];

    if (lastRetrieval)
      [client sendChangesSinceDate:lastRetrieval];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshing:)
                                                 name:PSFeedRefreshingNotification
                                               object:nil];
    
    _queue = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)refreshing:(NSNotification *)aNotification;
{
  if ([_feed isRefreshing])
    return;
  
  NSEnumerator *e = [_feed entryEnumeratorSortedBy:nil];
  PSEntry *entry = nil;
  
  while (entry = [e nextObject])
  {
    for (PSEnclosure *enclosure in [entry enclosures])
    {
      // add URLRequeust to queue
      NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[enclosure URL]];
      [_queue insertObject:request atIndex:0];
    }
  }
  
  // begin first download
  [self downloadNext];
  
  PSClient *client = [PSClient applicationClient];
  
  NSDate *date = [client dateLastUpdated];
  [[NSUserDefaults standardUserDefaults] setObject:date forKey:MFPLastFeedUpdateKey];
}

- (void)downloadNext
{
  NSURLDownload *download = [[NSURLDownload alloc] initWithRequest:[_queue lastObject] delegate:self];
  if (!download)
    NSLog(@"Something went wrong while downloading %@", [[download request] URL]);
  
  [_queue removeLastObject];
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
  NSString *destinationFilename = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:filename];
  
  [download setDestination:destinationFilename allowOverwrite:YES];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
  [self downloadNext];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSString *localPath = [[fm applicationSupportDirectory] stringByAppendingPathComponent:[[[[download request] URL] pathComponents] lastObject]];
  NSString *availableFilename = [[fm applicationSupportDirectory] stringByAppendingPathComponent:@"available.txt"];
  if ([fm fileExistsAtPath:localPath])
  {
    if (![fm fileExistsAtPath:availableFilename])
      [@"" writeToFile:availableFilename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    NSMutableString *available = [NSMutableString stringWithContentsOfFile:availableFilename
                                                                  encoding:NSUTF8StringEncoding
                                                                     error:NULL];
    [available appendFormat:@"%@\n", localPath];
    [available writeToFile:availableFilename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MFPNewTitleAvailableNotification object:nil];
  }
}

@end
