//
//  AppDelegate.h
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 07/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GRGlassWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet GRGlassWindow *window;
@property (weak) IBOutlet NSView *toolbarView;

@property (nonatomic, copy) NSMutableArray *pictures;
@property (weak) IBOutlet NSScrollView *scrollView;

@end