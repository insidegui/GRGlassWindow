//
//  AppDelegate.m
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 07/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
    NSView *_paddingView;
    NSCollectionView *_collectionView;
}

// don't look at this code too much, It's just for demonstration purposes :(

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.backgroundColor = [NSColor whiteColor];
    
    NSMutableArray *newPictures = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 20; i++) {
        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:@"/Library/Desktop Pictures/.thumbnails"] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
        
        NSURL *file;
        while (file = [dirEnum nextObject]) {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:file];
            [newPictures addObject:@{@"image": image}];
        }
    }

    self.pictures = [newPictures mutableCopy];
    
    self.window.subtitle = [NSString stringWithFormat:@"%ld pictures", self.pictures.count];
    
    self.window.accessoryView = self.toolbarView;
    
    // this adds some padding to the top of the scrollview, but it doesn't work very well =\
//    NSRect originalFrame = [self.scrollView.documentView frame];
//    _paddingView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(originalFrame), NSHeight(originalFrame))];
//    _paddingView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
//    _collectionView = self.scrollView.documentView;
//    [_collectionView removeFromSuperview];
//    
//    [_paddingView addSubview:_collectionView];
//    self.scrollView.documentView = _paddingView;
//    
//    originalFrame.origin.y -= 52;
//    _collectionView.frame = originalFrame;
}

@end