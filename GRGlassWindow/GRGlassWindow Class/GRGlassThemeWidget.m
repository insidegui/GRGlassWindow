//
//  GRGlassThemeWidget.m
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 07/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "GRGlassThemeWidget.h"
#import "GRGlassAccessoryWindow.h"

@implementation GRGlassThemeWidget
- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (!self) return nil;
    
    self.target = self;
    self.action = @selector(performAction:);
    
    return self;
}

- (void)performAction:(id)sender
{
    switch (self.type) {
        case GRGlassThemeWidgetTypeClose:
            [self.window.parentWindow close];
            break;
        case GRGlassThemeWidgetTypeMiniaturize:
            [self.window.parentWindow miniaturize:self];
            break;
        default:
            [self.window.parentWindow zoom:self];
            break;
    }
    
    [(GRGlassTitleBarView *)self.superview.superview resetWidgets];
}

- (void)setHover:(BOOL)hover
{
    _hover = hover;
    [self setNeedsDisplay];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    // update ourselves to be active
    self.hover = YES;
}

- (void)mouseExited:(NSEvent *)theEvent
{
    // update ourselves to be inactive
    self.hover = NO;
}

- (void)setType:(GRGlassThemeWidgetType)type
{
    _type = type;
    
    // if our type changes we need to update our look
    [self setNeedsDisplay];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *buttonPath = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(self.bounds, kGRGlassThemeWidgetInset, kGRGlassThemeWidgetInset)];
    
    if (self.type == GRGlassThemeWidgetTypeClose) {
        [[NSColor colorWithCalibratedRed:0.943 green:0.229 blue:0.238 alpha:0.9] set];
    } else if(self.type == GRGlassThemeWidgetTypeMiniaturize) {
        [[NSColor colorWithCalibratedRed:0.872 green:0.569 blue:0.249 alpha:0.9] set];
    } else {
        [[NSColor colorWithCalibratedRed:0.433 green:0.641 blue:0.305 alpha:0.9] set];
    }
    
    if (self.hover) [buttonPath fill];
    
    [buttonPath stroke];
}

@end
