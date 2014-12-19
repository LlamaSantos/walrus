//
//  UIImageExtensions.swift
//  walrus
//
//  Created by James White on 12/4/14.
//  Copyright (c) 2014 James White. All rights reserved.
//

import Foundation

extension UIImage {
    func fixOrientation() -> UIImage {
        if (self.imageOrientation == UIImageOrientation.Up) { return self }
        
        var transform = CGAffineTransformIdentity
        
        switch(self.imageOrientation){
        case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
                transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
                transform = CGAffineTransformTranslate(transform, self.size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            
        case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            
        case UIImageOrientation.UpMirrored, UIImageOrientation.Up:
            break
        }
        
        switch (self.imageOrientation) {
        case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientation.Left, UIImageOrientation.Right, UIImageOrientation.Down, UIImageOrientation.Up:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        var ctx = CGBitmapContextCreate(nil, UInt(self.size.width), UInt(self.size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage))
        
        CGContextConcatCTM(ctx, transform);
        switch (self.imageOrientation) {
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored, UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage)
            break
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage)
            break
        }
        
        // And now we just create a new UIImage from the drawing context
        var cgimg = CGBitmapContextCreateImage(ctx)
        return UIImage(CGImage: cgimg)!
        //CGContextRelease(ctx);
        //CGImageRelease(cgimg);
    }
}