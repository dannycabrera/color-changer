//
//  AppDelegate.h
//  Glyphish Color Changer
//
//  Created by Rudd Fawcett on 7/15/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GCCImportView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign)            IBOutlet NSWindow      *window;
@property (strong, nonatomic) IBOutlet GCCImportView *importView;

@end
