//
//  MbHUDuser.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/18.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "MbHUDuser.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface MbHUDuser()<MBProgressHUDDelegate>
@end
@implementation MbHUDuser

-(void)showHUDWithText:(NSString*)text inView:(UIView*)view{
    MBProgressHUD* hub=[MBProgressHUD showHUDAddedTo:view animated:YES];
    hub.mode=MBProgressHUDModeText;
    hub.delegate=self;
    hub.label.text=text;
    hub.bezelView.layer.cornerRadius=20.0;
    hub.bezelView.backgroundColor=[UIColor colorWithRed:88/255.0 green:187/255.0 blue:255/255.0 alpha:1.0];
    [hub hideAnimated:YES afterDelay:2];
}
-(void)showHUDWithIndex:(int)index subProgress:(float)subProgress andCount:(unsigned long)count inView:(UIView*)view{
    MBProgressHUD* hub=[MBProgressHUD showHUDAddedTo:view animated:YES];
    hub.mode=MBProgressHUDModeDeterminateHorizontalBar;
    hub.delegate=self;
    hub.label.text=[NSString stringWithFormat:@"第%d张图片正在上传",index];
    hub.bezelView.layer.cornerRadius=20.0;
     hub.bezelView.backgroundColor=[UIColor colorWithRed:88/255.0 green:187/255.0 blue:255/255.0 alpha:1.0];
    hub.progress=((index-1)+subProgress)/count;
    //[hub hideAnimated:YES afterDelay:10];
}
-(void)hidHUDinView:(UIView*)view{
    [MBProgressHUD hideHUDForView:view animated:YES];
    [view removeFromSuperview];
}
-(void)hudWasHidden:(MBProgressHUD *)hud{
    [hud removeFromSuperview];
    hud=nil;
    //NSLog(@"dismiss");
}
@end
