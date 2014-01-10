//
//  GRGlassThemeWidget.h
//  GRGlassWindow
//
//  Created by Guilherme Rambo on 07/01/14.
//  Copyright (c) 2014 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kGRGlassThemeWidgetSize 12
#define kGRGlassThemeWidgetInset 1

// window widget types
typedef enum {
    GRGlassThemeWidgetTypeClose = 1,
    GRGlassThemeWidgetTypeMiniaturize = 2,
    GRGlassThemeWidgetTypeZoom = 3
} GRGlassThemeWidgetType;

@interface GRGlassThemeWidget : NSButton

@property (nonatomic, assign) GRGlassThemeWidgetType type;
@property (nonatomic, assign) BOOL hover;

@end
