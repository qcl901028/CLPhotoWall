//
//  UIImage+PhotoAsset.m
//  PhotoKit
//
//  Created by hezhijingwei on 2017/2/3.
//  Copyright © 2017年 秦传龙. All rights reserved.
//

#import "UIImage+PhotoAsset.h"
#import <objc/runtime.h>
#import "CLPhotoWall.h"

@implementation UIImage (PhotoAsset)

+ (void)initialize {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self cl_methodSwizzlingedWithOriginalSelector:@selector(imageNamed:) bySwizzlingedSelector:@selector(cl_imageNamed:)];
    });
    
    
}


+ (void)cl_methodSwizzlingedWithOriginalSelector:(SEL)aSelector bySwizzlingedSelector:(SEL)selector {
    
    Method OriginalMethod = class_getInstanceMethod([self class], aSelector);
    Method selectorMethod = class_getInstanceMethod([self class], selector);
    
    BOOL didAddMethod = class_addMethod([self class], aSelector, (IMP)method_getImplementation(selectorMethod), method_getTypeEncoding(selectorMethod));
    
    if (didAddMethod) {
        
        class_replaceMethod([self class], selector, method_getImplementation(OriginalMethod), method_getTypeEncoding(OriginalMethod));
        
    } else {
    
        method_exchangeImplementations(OriginalMethod, selectorMethod);
        
        
    }
    
    
}


- (UIImage *)cl_imageNamed:(NSString *)imageName {
    
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"CLPhotoWall")];
    NSURL *url = [bundle URLForResource:@"CLPhotoWall" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    
    NSString *path = [imageBundle pathForResource:imageName ofType:@"png"];

//    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    [self cl_imageNamed:imageName];
    return [UIImage imageWithContentsOfFile:path];
    
}



@end
