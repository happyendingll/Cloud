//
//  MbHUDuser.h
//  Cloud
//
//  Created by 曾志远 on 2017/12/18.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MbHUDuser : NSObject
-(void)showHUDWithText:(NSString*)text inView:(UIView*)view;
-(void)showHUDWithIndex:(int)index subProgress:(float)subProgress andCount:(unsigned long)count inView:(UIView*)view;
-(void)hidHUDinView:(UIView*)view;
@end
