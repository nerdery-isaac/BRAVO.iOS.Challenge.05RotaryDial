//
//  NRDImageViewIgnoringTransparentTouches.m
//  RotaryDial
//
//  Created by Isaac Greenspan on 3/19/14.
//  Copyright (c) 2014 The Nerdery. All rights reserved.
//

#import "NRDImageViewIgnoringTransparentTouches.h"

#import <QuartzCore/QuartzCore.h>

@implementation NRDImageViewIgnoringTransparentTouches

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Code based on https://github.com/ole/OBShapedButton/blob/master/UIImage%2BColorAtPixel/UIImage%2BColorAtPixel.m
    
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height), point)) {
        return NO;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.image.CGImage;
    NSUInteger width = self.image.size.width;
    NSUInteger height = self.image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
//    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
//    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
//    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;

    BOOL transparent = alpha < 0.01f;
    return !transparent;
}

@end
