//
//  HexToRGB.h
//  CamConnect
//
//  Created by Sorround apps on 1/25/11.
//  Copyright 2011 sorroundapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HexToRGB : NSObject {

}

+ (UIColor *) colorForHex:(NSString *)hexColor;
@end
