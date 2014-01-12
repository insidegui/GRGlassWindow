//
//  NSWindow+Screenshot.m
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 12/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "NSWindow+Screenshot.h"

@implementation NSWindow (Screenshot)

- (NSImage *)screenshot
{
    NSImage * image = [[NSImage alloc] initWithCGImage:[self windowImageShot] size:[self frame].size];
    [image setDataRetained:YES];
    [image setCacheMode:NSImageCacheNever];
    return image;
}


- (CGImageRef)windowImageShot
{
    CGWindowID windowID = (CGWindowID)[self windowNumber];
    CGWindowImageOption imageOptions = kCGWindowImageDefault;
    CGWindowListOption singleWindowListOptions = kCGWindowListOptionOnScreenAboveWindow|kCGWindowListOptionIncludingWindow|kCGWindowListExcludeDesktopElements;
    CGRect imageBounds = CGRectMake(self.frame.origin.x, NSHeight(self.screen.frame)-NSHeight(self.frame)-self.frame.origin.y, NSWidth(self.frame), NSHeight(self.frame));
    
	CGImageRef windowImage = CGWindowListCreateImage(imageBounds, singleWindowListOptions, windowID, imageOptions);

    return windowImage;
}

@end
