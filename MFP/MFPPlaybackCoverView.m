//
//  MFPPlaybackCoverView.m
//  MFP
//
//  Created by Stefan Graupner on 26.02.13.
//  Copyright (c) 2013 meanderingsoul.com. All rights reserved.
//

#import "MFPPlaybackCoverView.h"

@interface MFPPlaybackCoverView ()
{
  BOOL            _hasFocus;
  BOOL            _clicked;
  NSTrackingArea *_focusArea;
}

-(void)resetColor;

@end

@implementation MFPPlaybackCoverView

-(id)initWithFrame:(NSRect)frameRect
{
  self = [super initWithFrame:frameRect];
  if (self)
  {
    [self addObserver:self forKeyPath:@"currentlyPlaying" options:NSKeyValueObservingOptionNew context:NULL];
  }
  return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
  [self setNeedsDisplay:YES];
}

-(void)updateTrackingAreas
{
  if(_focusArea != nil) {
    [self removeTrackingArea:_focusArea];
  }
  
  _focusArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways)
                                                  owner:self
                                               userInfo:nil];
  [self addTrackingArea:_focusArea];
  
  [super updateTrackingAreas];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
  _hasFocus = YES;
  [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent
{
  _hasFocus = NO;
  [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)theEvent
{
  _clicked = YES;
  [self setNeedsDisplay:YES];
  [self performSelector:@selector(resetColor) withObject:nil afterDelay:0.15];
  
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  [[self target] performSelector:[self action] withObject:self];
  #pragma clang diagnostic pop
}

-(void)drawRect:(NSRect)dirtyRect
{
  [super drawRect:dirtyRect];
  
  // if the control has no focus, nothing else needs to be drawn
  if (!_hasFocus) return;
  
  [[NSColor highlightColor] set];
  if (_clicked)
  {
    [[NSColor selectedControlColor] set];
  }
  
  // circle
  NSRect circleRect = [self bounds];
  
  circleRect.origin.x += 20;
  circleRect.origin.y += 20;
  
  circleRect.size.width  -= 40;
  circleRect.size.height -= 40;
  
  NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:circleRect];
  [circle setLineWidth:5.0];
  [circle stroke];
  
  // play or pause?
  if (_currentlyPlaying)
  {
    // draw pause bars
    /*
     divide area in five parts:
     - bar width: 2 parts
     - space in between: 1 part
     */
    
    CGFloat x, y, size;
    
    size = circleRect.size.height / 2;
    x    = circleRect.origin.x + (size / 2);
    y    = circleRect.origin.y + size;
    
    CGFloat dividerWidth = size / 5;
    CGFloat barWidth     = dividerWidth * 2;
    
    NSPoint barLB, barLT, barRT, barRB;
    
    NSBezierPath *bar1 = [[NSBezierPath alloc] init];
    
    barLB = NSMakePoint(x, y - (size / 2));
    barLT = NSMakePoint(barLB.x, y + (size / 2));
    barRT = NSMakePoint(barLB.x + barWidth, barLT.y);
    barRB = NSMakePoint(barRT.x, barLB.y);
    
    [bar1 moveToPoint:barLB];
    [bar1 lineToPoint:barLT];
    [bar1 lineToPoint:barRT];
    [bar1 lineToPoint:barRB];
    
    [bar1 fill];
    
    NSBezierPath *bar2 = [[NSBezierPath alloc] init];
    
    barLB.x += barWidth + dividerWidth;
    barLT.x += barWidth + dividerWidth;
    barRB.x += barWidth + dividerWidth;
    barRT.x += barWidth + dividerWidth;
    
    [bar2 moveToPoint:barLB];
    [bar2 lineToPoint:barLT];
    [bar2 lineToPoint:barRT];
    [bar2 lineToPoint:barRB];
    
    [bar2 fill];
  } else
  {
    // draw a play triangle
    NSPoint A, B, C;
    
    CGFloat x, y, size;
    size = circleRect.size.height / 2;
    x    = circleRect.origin.x + 5 * (size / 8); // "irgendwas mit Pythagoras, ne?"
    y    = circleRect.origin.y + size;
    
    A = NSMakePoint(x, y - (size / 2));
    B = NSMakePoint(A.x, y + (size / 2));
    C = NSMakePoint(B.x + size, y);
    
    NSBezierPath *triangle = [[NSBezierPath alloc] init];
    [triangle moveToPoint:A];
    [triangle lineToPoint:B];
    [triangle lineToPoint:C];
    
    [triangle fill];
  }
}

-(void)resetColor
{
  _clicked = NO;
  [self setNeedsDisplay:YES];
}

@end
