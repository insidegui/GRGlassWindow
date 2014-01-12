//
//  GRGlassWindow.m
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 07/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "GRGlassWindow.h"
#import "GRGlassAccessoryWindow.h"
#import <QuartzCore/QuartzCore.h>

#import "NSWindow+Screenshot.h"

@interface GRGlassWindow ()

@property (nonatomic, readonly) GRGlassWindowFrame *frameView;
@property (strong) GRGlassAccessoryWindow *titleWindow;
@property (strong) NSImageView *screenshotImageView;

@end

@implementation GRGlassWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if(!self) return nil;

    // initialize an accessory window which is used as our title bar
    self.titleWindow = [[GRGlassAccessoryWindow alloc] initWithContentRect:[self titleWindowRect] styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];
    // add the accessory window as our child
    [self addChildWindow:self.titleWindow ordered:NSWindowAbove];
    
    // when this window is resized, the child window should be resized as well
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeChild:) name:NSWindowDidResizeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeScreenshotImage:) name:NSWindowDidDeminiaturizeNotification object:self];
    
    return self;
}

// returns the correct rect for the title bar window
- (NSRect)titleWindowRect
{
    return NSMakeRect(self.frame.origin.x, self.frame.origin.y+NSHeight(self.frame)-kGRGlassWindowTitleBarHeight-0.5, NSWidth(self.frame), kGRGlassWindowTitleBarHeight);
}

// this tells appkit we want the window's frame to be a GRGlassWindowFrame
+ (Class)frameViewClassForStyleMask:(NSInteger)styleMask
{
    return [GRGlassWindowFrame class];
}

// this makes our custom window frame have the correct appearance and shadow
- (BOOL)_usesCustomDrawing
{
    return NO;
}

// called from NSWindowDidResizeNotification
- (void)resizeChild:(NSNotification *)notification
{
    [self.titleWindow setFrame:[self titleWindowRect] display:YES animate:NO];
}

- (void)miniaturize:(id)sender
{
    // when the window miniaturizes, we need to take a screenshot including the
    // child window, this is not done by default,
    // so we take a screenshot of the window including the child and
    // put it on the window, giving the illusion that everything is one window
    NSImage *screenshot = [self screenshot];
    
    if(!self.screenshotImageView) self.screenshotImageView = [[NSImageView alloc] initWithFrame:NSZeroRect];
    self.screenshotImageView.frame = NSMakeRect(0, 0, NSWidth([self.contentView frame]), NSHeight([self.contentView frame]));
    self.screenshotImageView.image = screenshot;
    
    [self.contentView addSubview:self.screenshotImageView];
    
    // there has to be a slight delay before the window is actually miniaturized,
    // otherwise the screenshot would not appear on time
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [super miniaturize:sender];
    });
}

// called from NSWindowDidDeminiaturizeNotification
- (void)removeScreenshotImage:(NSNotification *)notification
{
    // here we remove the screenshot used on miniaturization
    [self.screenshotImageView removeFromSuperview];
}

- (void)setTitle:(NSString *)aString
{
    [super setTitle:aString];
    
    // our title is really displayed by the title bar window
    self.titleWindow.title = aString;
}

- (void)setHidesTitleBar:(BOOL)hidesTitleBar
{
    _hidesTitleBar = hidesTitleBar;

    self.titleWindow.hides = hidesTitleBar;
}

- (GRGlassWindowFrame *)frameView
{
    return (GRGlassWindowFrame *)[self.contentView superview];
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
    
    // our subtitle is really displayed by the title bar window
    self.titleWindow.subtitle = subtitle;
}

- (void)setAccessoryView:(NSView *)accessoryView
{
    self.titleWindow.accessoryView = accessoryView;
}

- (NSView *)accessoryView
{
    return self.titleWindow.accessoryView;
}

@end

// this view is just a "proxy" so we can track mouse events to show and hide the title bar
@implementation GRGlassWindowFrameProxyView
{
    NSTrackingArea *_area;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.window.backgroundColor setFill];
    NSRectFill(dirtyRect);
}

- (void)updateTrackingAreas
{
    if(_area) [self removeTrackingArea:_area];
    
    NSRect trackingRect = NSMakeRect(0, 0, NSWidth(self.frame), NSHeight(self.frame)-kGRGlassWindowTitleBarHeight);
    _area = [[NSTrackingArea alloc] initWithRect:trackingRect options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:_area];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    if([self.delegate respondsToSelector:@selector(mouseDidEnterFrame)]) [self.delegate mouseDidEnterFrame];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    if([self.delegate respondsToSelector:@selector(mouseDidExitFrame)]) [self.delegate mouseDidExitFrame];
}

@end

// this is the window frame, responsible for it's look
@implementation GRGlassWindowFrame
{
    id _contentView;

    GRGlassWindowFrameProxyView *_frameProxyView;
}

// this makes the content view flush with the window's top
+ (double)_titlebarHeight:(unsigned long long)arg1
{
    return 0;
}
- (BOOL)topCornerRounded
{
    return YES;
}
- (BOOL)_wantsTitleBar
{
    return NO;
}

- (void)_setContentView:(id)view
{
    // if we don't do this we may have drawing glitches
    [self setWantsLayer:YES];
    
    // we use this to create the frame proxy view and insert it into our hierarchy
    _frameProxyView = [[GRGlassWindowFrameProxyView alloc] initWithFrame:[view frame]];
    _frameProxyView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable|NSViewMinXMargin|NSViewMinYMargin;
    _frameProxyView.delegate = self;
    [self addSubview:_frameProxyView];
    
    [super _setContentView:view];
}

- (void)hideTitleBar
{
    if(!self.hidesTitleBar) return;
    
    GRGlassWindow *window = (GRGlassWindow *)self.window;
    [window.titleWindow.animator setAlphaValue:0];
}

- (void)showTitleBar
{
    if(!self.hidesTitleBar) return;
    
    GRGlassWindow *window = (GRGlassWindow *)self.window;
    [window.titleWindow.animator setAlphaValue:1];
}

- (void)mouseDidEnterFrame
{
    [self showTitleBar];
}

- (void)mouseDidExitFrame
{
    [self hideTitleBar];
}

@end