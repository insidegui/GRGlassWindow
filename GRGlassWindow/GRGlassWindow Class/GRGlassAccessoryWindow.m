//
//  GRGlassAccessoryWindow.m
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 08/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "GRGlassAccessoryWindow.h"
#import "GRGlassThemeWidget.h"
#import <QuartzCore/QuartzCore.h>

#define kGRGlassAccessoryWindowDefaultBlurRadius 20

@implementation GRGlassAccessoryWindow
{
    // this view is used to drag our parent window
    GRGlassAccessoryWindowTitleProxyView *_titleProxyView;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:NSTitledWindowMask backing:bufferingType defer:flag];
    if(!self) return nil;
    
    // this window will not look like a window,
    // so we make sure it's not movable,
    // has no shadow and is not opaque (this is important)
    [self setMovable:NO];
    [self setOpaque:NO];
    [self setHasShadow:NO];
    
    // white background with a little transparency
    self.backgroundColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.8];
    
    // set default blur radius
    _blurRadius = kGRGlassAccessoryWindowDefaultBlurRadius;
    
    // here we create our title proxy view, used to drag the parent window
    _titleProxyView = [[GRGlassAccessoryWindowTitleProxyView alloc] initWithFrame:[self.contentView superview].bounds];
    _titleProxyView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable|NSViewMinXMargin|NSViewMinYMargin;
    [self setContentView:_titleProxyView];
    
    // if we don't call this our window's controls can't receive events
    [self orderWindow:NSWindowAbove relativeTo:[self.parentWindow windowNumber]];
    [self.parentWindow becomeMainWindow];
    
    return self;
}

+ (Class)frameViewClassForStyleMask:(NSInteger)styleMask
{
    return [GRGlassTitleBarView class];
}

- (BOOL)_usesCustomDrawing
{
    return NO;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return NO;
}

- (void)orderFront:(id)sender
{
    [super orderFront:sender];
    [self installBlur];
}

- (void)setParentWindow:(NSWindow *)window
{
    [super setParentWindow:window];
    [self installBlur];
}

- (void)setBlurRadius:(int)blurRadius
{
    _blurRadius = blurRadius;
    [self installBlur];
}

// this method will setup the window's background blur
// it must be called after the window is on screen
- (void)installBlur
{
    CGSConnection connection = CGSDefaultConnectionForThread();
    CGSSetWindowBackgroundBlurRadius(connection, [self windowNumber], self.blurRadius);
}

- (void)setTitle:(NSString *)aString
{
    [super setTitle:aString];
    
    GRGlassTitleBarView *titleBarView = (GRGlassTitleBarView *)[self.contentView superview];
    titleBarView.title = aString;
}

- (void)setSubtitle:(NSString *)subtitle
{
    GRGlassTitleBarView *titleBarView = (GRGlassTitleBarView *)[self.contentView superview];
    titleBarView.subtitle = subtitle;
}

- (void)setHides:(BOOL)hides
{
    _hides = hides;
    GRGlassTitleBarView *titleBarView = (GRGlassTitleBarView *)[self.contentView superview];
    titleBarView.hides = hides;
}

- (void)setAccessoryView:(NSView *)accessoryView
{
    _accessoryView = accessoryView;
    [_accessoryView setFrameOrigin:NSMakePoint(NSWidth(self.frame)-NSWidth(_accessoryView.frame), 0)];
    _accessoryView.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin;
    [self.contentView addSubview:_accessoryView];
}

@end

// this view will drag It's window's parent window, basically working like a title bar :)
@implementation GRGlassAccessoryWindowTitleProxyView
{
    NSTrackingArea *_area;
    NSPoint _dragStart;
    BOOL _dragged;
}

- (void)updateTrackingAreas
{
    if(_area) [self removeTrackingArea:_area];
    
    _area = [[NSTrackingArea alloc] initWithRect:self.frame options:NSTrackingInVisibleRect|NSTrackingMouseMoved|NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:_area];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    _dragStart = [theEvent locationInWindow];
}

#define kOSXMenuBarHeight 22.0
- (void)mouseDragged:(NSEvent *)theEvent
{
    _dragged = YES;
    
    NSPoint mouseLocation = [NSEvent mouseLocation];

    CGFloat windowY = round(mouseLocation.y-_dragStart.y-NSHeight(self.window.parentWindow.frame)+NSHeight(self.window.frame));
    CGFloat maxWindowY = round(NSHeight(self.window.parentWindow.screen.frame)-NSHeight(self.window.parentWindow.frame)-kOSXMenuBarHeight);
    
    windowY = MIN(windowY, maxWindowY);
    
    NSPoint newPoint = NSMakePoint(mouseLocation.x-_dragStart.x, windowY);
    [self.window.parentWindow setFrameOrigin:newPoint];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if(!_dragged) return;
    
    [self.window.parentWindow becomeKeyWindow];
    _dragged = NO;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

@end

@implementation GRGlassTitleBarView
{
    GRGlassThemeWidget *_closeWidget;
    GRGlassThemeWidget *_miniaturizeWidget;
    GRGlassThemeWidget *_zoomWidget;
    
    NSTrackingArea *_widgetTrackingArea;
    
    NSTrackingArea *_generalTrackingArea;
}

+ (NSDictionary *)widgetUserInfo
{
    static NSDictionary *_widgetUserInfo;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _widgetUserInfo = @{@"isWidget": @1};
    });
    
    return _widgetUserInfo;
}

- (void)_setContentView:(id)view
{
    [super _setContentView:view];
    
    [self installWidgets];
}

#define kGRGlassThemeWidgetSpacing 8.0

- (CGFloat)widgetY
{
    return (self.centerWidgets) ? round(kGRGlassWindowTitleBarHeight/2-kGRGlassThemeWidgetSize/2) : NSHeight(self.frame)-kGRGlassThemeWidgetSize-kGRGlassThemeWidgetSpacing;
}

- (void)installWidgets
{
    // centered widgets
//    CGFloat widgetY = kGRGlassWindowTitleBarHeight/2-kGRGlassThemeWidgetSize/2;
    
    CGFloat widgetY = [self widgetY];
    
    _closeWidget = [[GRGlassThemeWidget alloc] initWithFrame:NSMakeRect(kGRGlassThemeWidgetSpacing, widgetY, kGRGlassThemeWidgetSize, kGRGlassThemeWidgetSize)];
    _closeWidget.type = GRGlassThemeWidgetTypeClose;
    
    _miniaturizeWidget = [[GRGlassThemeWidget alloc] initWithFrame:NSMakeRect(_closeWidget.frame.origin.x+kGRGlassThemeWidgetSize+kGRGlassThemeWidgetSpacing, widgetY, kGRGlassThemeWidgetSize, kGRGlassThemeWidgetSize)];
    _miniaturizeWidget.type = GRGlassThemeWidgetTypeMiniaturize;
    
    _zoomWidget = [[GRGlassThemeWidget alloc] initWithFrame:NSMakeRect(_miniaturizeWidget.frame.origin.x+kGRGlassThemeWidgetSize+kGRGlassThemeWidgetSpacing, widgetY, kGRGlassThemeWidgetSize, kGRGlassThemeWidgetSize)];
    _zoomWidget.type = GRGlassThemeWidgetTypeZoom;
    
    [self.window.contentView addSubview:_closeWidget];
    [self.window.contentView addSubview:_miniaturizeWidget];
    [self.window.contentView addSubview:_zoomWidget];
}

- (void)resetWidgets
{
    _closeWidget.hover = NO;
    _miniaturizeWidget.hover = NO;
    _zoomWidget.hover = NO;
}

// small title bar height just to make the top corner rounded
+ (double)_titlebarHeight:(unsigned long long)arg1
{
    return 5;
}

// makes the contentview stick to the top of the window ignoring the invisible title bar
+ (double)_contentToFrameMaxYHeight:(unsigned long long)arg1
{
    return 0;
}

// draws a path making the top rounded and the bottom flat
- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor clearColor] setFill];
    NSRectFill(dirtyRect);
    
    CGFloat cornerRadius = 3;
    NSRect innerRect = NSInsetRect(self.frame, cornerRadius, cornerRadius);
    NSBezierPath *barPath = [NSBezierPath bezierPath];
    [barPath moveToPoint: NSMakePoint(NSMinX(self.frame), NSMinY(self.frame))];
    [barPath lineToPoint: NSMakePoint(NSMaxX(self.frame), NSMinY(self.frame))];
    [barPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(innerRect), NSMaxY(innerRect)) radius:cornerRadius startAngle:0 endAngle:90];
    [barPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(innerRect), NSMaxY(innerRect)) radius:cornerRadius startAngle:90 endAngle:180];
    [barPath closePath];
    
    [barPath addClip];
    
    [self.window.backgroundColor setFill];
    NSRectFill(dirtyRect);

    NSRect separatorRect = NSMakeRect(0, .5, NSWidth(self.frame), .5);
    [[NSColor colorWithCalibratedWhite:0.1 alpha:1] setFill];
    NSRectFill(separatorRect);
    
    [self drawTitle];
}

- (void)drawTitle
{
    if(!self.title) return;
    
    NSShadow *titleShadow = [[NSShadow alloc] init];
    titleShadow.shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.7];
    titleShadow.shadowOffset = NSMakeSize(0, -1);
    
    NSDictionary *titleAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"Roboto-Medium" size:14.0],
                                      NSForegroundColorAttributeName : [NSColor colorWithCalibratedWhite:0.1 alpha:0.9],
                                      NSShadowAttributeName : titleShadow};
    NSAttributedString *titleAttributedString = [[NSAttributedString alloc] initWithString:self.title attributes:titleAttributes];
    
    NSPoint titlePoint;
    if(self.centerWidgets) {
        titlePoint = NSMakePoint(round(NSWidth(self.frame)/2-titleAttributedString.size.width/2), NSHeight(self.frame)-titleAttributedString.size.height-1);
    } else {
        titlePoint = NSMakePoint(round(NSWidth(self.frame)/2-titleAttributedString.size.width/2), [self widgetY]-3);
    }
    
    [titleAttributedString drawAtPoint:titlePoint];
    
    if(!self.subtitle) return;
    
    NSDictionary *subtitleAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"Roboto-Regular" size:12.0], NSForegroundColorAttributeName : [NSColor colorWithCalibratedWhite:0.3 alpha:0.8]};
    NSAttributedString *subtitleAttributedString = [[NSAttributedString alloc] initWithString:self.subtitle attributes:subtitleAttributes];
    NSPoint subtitlePoint = NSMakePoint(round(NSWidth(self.frame)/2-subtitleAttributedString.size.width/2), NSHeight(self.frame)-subtitleAttributedString.size.height-25);
    [subtitleAttributedString drawAtPoint:subtitlePoint];
}

// makes the bottom corner flat
- (void)_maskCorners:(NSUInteger)corners clipRect:(NSRect)rect
{
    return;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setNeedsDisplay:YES];
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
    [self setNeedsDisplay:YES];
}

// this is for the traffic lights
- (void)updateTrackingAreas
{
    [self removeTrackingArea:_widgetTrackingArea];
    [self removeTrackingArea:_generalTrackingArea];
    
    NSRect widgetsRect = NSMakeRect(kGRGlassThemeWidgetSpacing,
                                    _closeWidget.frame.origin.y,
                                    (kGRGlassThemeWidgetSize+kGRGlassThemeWidgetSpacing-kGRGlassThemeWidgetInset)*3,
                                    kGRGlassThemeWidgetSize);
    
    NSTrackingAreaOptions widgetsOptions = NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited|NSTrackingEnabledDuringMouseDrag;
    
    _widgetTrackingArea = [[NSTrackingArea alloc] initWithRect:widgetsRect
                                                  options:widgetsOptions
                                                  owner:self
                                                  userInfo:[[self class] widgetUserInfo]];
    
    [self addTrackingArea:_widgetTrackingArea];
    
    _generalTrackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways|NSTrackingInVisibleRect owner:self userInfo:nil];
    [self addTrackingArea:_generalTrackingArea];
    
    [super updateTrackingAreas];
}

- (BOOL)isWidgetEvent:(NSEvent *)theEvent
{
    if(theEvent.userData) {
        if (theEvent.userData == (__bridge void *)([[self class] widgetUserInfo])) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    if(self.hides) {
        [NSAnimationContext beginGrouping];
        self.window.animator.alphaValue = 1;
        [NSAnimationContext endGrouping];
    }
    
    if (![self isWidgetEvent:theEvent]) return;
    
    for (id widget in [self.window.contentView subviews]) {
        if ([widget isKindOfClass:[GRGlassThemeWidget class]]) {
            [widget mouseEntered:theEvent];
        }
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    if(self.hides) {
        [NSAnimationContext beginGrouping];
        self.window.animator.alphaValue = 0;
        [NSAnimationContext endGrouping];
    }
    
    if (![self isWidgetEvent:theEvent]) return;
    
    for (id widget in [self.window.contentView subviews]) {
        if ([widget isKindOfClass:[GRGlassThemeWidget class]]) {
            [widget mouseExited:theEvent];
        }
    }
}

@end
