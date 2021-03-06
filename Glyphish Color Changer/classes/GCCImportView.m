//
//  GCCImportView.m
//  Glyphish Color Changer
//
//  Created by Rudd Fawcett on 7/15/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import "GCCImportView.h"

@implementation GCCImportView

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationGeneric;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = NO;
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    
    NSString *iconTitle = [[[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType] count] == 1 ? @"icon" : @"icons";
    
    panel.title = [NSString stringWithFormat:@"Pick a folder to export your new %@.", iconTitle];
    
    long result = [panel runModal];
    
    if (result == NSOKButton) {
        NSString *folderPath = panel.URL.path;

        NSArray *draggedFiles = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        
        for (NSString *path in draggedFiles) {
            if ([[path pathExtension] isEqualToString:@"png"]) {
                NSImage *originalImage = [[NSImage alloc] initWithContentsOfFile:path];
                
                NSImage *maskedImage = [NSImage maskedImage:originalImage withNSColor:self.colorWell.color];
                
                [self savePNGImage:maskedImage atPath:[folderPath stringByAppendingPathComponent:[path lastPathComponent]]];
            }
            else if ([[path pathExtension] isEqualToString:@"svg"]) {
                NSData *data = [NSData dataWithContentsOfFile:path];
                NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                if ([[NSFileManager defaultManager] copyItemAtPath:path toPath:[folderPath stringByAppendingPathComponent:[path lastPathComponent]] error:nil]) {
                    NSString *replacementString = [NSString stringWithFormat:@" fill=\"%@\"",[self hexadecimalValueOfAnNSColor:self.colorWell.color]];
                    
                    contents = [contents stringByReplacingOccurrencesOfString:@" fill=\"#000000\"" withString:replacementString];
                    
                    [[NSFileManager defaultManager] createFileAtPath:[folderPath stringByAppendingPathComponent:[path lastPathComponent]] contents:[contents dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
                    
                    // Testing:
                    
                    /*
                    NSData *data = [NSData dataWithContentsOfFile:[folderPath stringByAppendingPathComponent:[path lastPathComponent]]];
                    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    NSLog(@"%@",string);
                    */
                }
            }
        }
    }
}

- (void)savePNGImage:(NSImage *)image atPath:(NSString *)path {
    CGImageRef cgImageRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *newRepresentation = [[NSBitmapImageRep alloc] initWithCGImage:cgImageRef];
    newRepresentation.size = image.size;
    
    NSData *png = [newRepresentation representationUsingType:NSPNGFileType properties:nil];
    if ([png writeToFile:path atomically:YES]) {
        NSLog(@"%@",path);
        NSLog(@"good");
    };
}

// https://developer.apple.com/library/mac/qa/qa1576/_index.html
- (NSString *)hexadecimalValueOfAnNSColor:(NSColor *)color {
    double redFloatValue, greenFloatValue, blueFloatValue;
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;
    
    //Convert the NSColor to the RGB color space before we can access its components
    NSColor *convertedColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    if (convertedColor) {
        [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:NULL];
        
        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue=redFloatValue * 255.99999f;
        greenIntValue=greenFloatValue * 255.99999f;
        blueIntValue=blueFloatValue * 255.99999f;
        
        // Convert the numbers to hex strings
        redHexValue=[NSString stringWithFormat:@"%02x", redIntValue];
        greenHexValue=[NSString stringWithFormat:@"%02x", greenIntValue];
        blueHexValue=[NSString stringWithFormat:@"%02x", blueIntValue];
        
        // Concatenate the red, green, and blue components' hex strings together with a "#"
        return [NSString stringWithFormat:@"#%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    
    return nil;
}

@end
