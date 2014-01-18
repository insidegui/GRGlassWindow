//
//  GRGlassWindow.h
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 07/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PrivateStuff.h"

@class GRGlassWindowFrame;

@interface GRGlassWindow : NSWindow

// an accessory view placed on the right hand side of the window,
// this can be used to put a button or other view,
// if you want to put more than one button you can
// make a view with the buttons inside and use
// the view as the accessory view
@property (nonatomic, assign) NSView *accessoryView;

// this makes the titlebar fade out when the mouse leaves the window
@property (nonatomic, assign) BOOL hidesTitleBar;

// smaller text below the title
@property (nonatomic, copy) NSString *subtitle;

// Title bar gradient
@property (nonatomic, copy) NSGradient *titleBarGradient;

@end




/* if you just want to use the glass window, the stuff below is not important */

@protocol GRGlassWindowFrameProxyViewDelegate <NSObject>

- (void)mouseDidEnterFrame;
- (void)mouseDidExitFrame;

@end

@interface GRGlassWindowFrameProxyView : NSView

@property (nonatomic, assign) id<GRGlassWindowFrameProxyViewDelegate> delegate;

@end

@interface GRGlassWindowFrame : NSThemeFrame <GRGlassWindowFrameProxyViewDelegate>

@property (nonatomic, assign) BOOL hidesTitleBar;

@end