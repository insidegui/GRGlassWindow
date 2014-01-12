//
//  NSWindow+Screenshot.h
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 12/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

// based on this gist: https://gist.github.com/fernyb/890044

#import <Cocoa/Cocoa.h>

@interface NSWindow (Screenshot)

- (NSImage *)screenshot;

@end
