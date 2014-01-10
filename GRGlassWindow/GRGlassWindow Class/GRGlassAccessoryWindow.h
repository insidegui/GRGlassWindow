//
//  GRGlassAccessoryWindow.h
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 08/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

/*
 GRGlassAccessoryWindow is a NSWindow subclass used as the titlebar of GRGlassWindow,
 I decided to use a child window instead of NSView or CALayers because the drawing performance is a lot better,
 this also makes It easier to add views to the title bar
 */

/* You don't have to deal with this, but if you want to customize the title bar look, go ahead :) */

#import <Cocoa/Cocoa.h>
#import "PrivateStuff.h"

#define kGRGlassWindowTitleBarHeight 52.0

@interface GRGlassAccessoryWindow : NSWindow

@property (nonatomic, strong) NSView *accessoryView;

@property (nonatomic, assign) int blurRadius;
@property (nonatomic, assign) BOOL hides;
@property (nonatomic, copy) NSString *subtitle;

@end

@interface GRGlassAccessoryWindowTitleProxyView : NSControl

@end

@interface GRGlassTitleBarView : NSThemeFrame

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) BOOL centerWidgets;

@property (nonatomic, assign) BOOL hides;

- (void)resetWidgets;

@end