//
//  PrivateStuff.h
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 08/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

/* private classes, methods and functions used by GRGlassWindow and friends */

#import <Cocoa/Cocoa.h>

#pragma mark AppKit

@interface NSWindow (AppKitPrivate)
+ (Class)frameViewClassForStyleMask:(NSInteger)styleMask;
- (BOOL)_usesCustomDrawing;
@end

@interface NSThemeFrame : NSView
- (void)shapeWindow;
- (void)_setContentView:(id)view;
@end

#pragma mark Core Graphics

// these are private Core Graphics calls we use to blur the window's background
typedef void * CGSConnection;
extern CGError CGSSetWindowBackgroundBlurRadius(CGSConnection connection, NSInteger windowNumber, int radius);
extern CGSConnection CGSDefaultConnectionForThread();