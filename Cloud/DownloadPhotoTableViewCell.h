//
//  DownloadPhotoTableViewCell.h
//  Cloud
//
//  Created by 曾志远 on 2017/12/15.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadPhotoTableViewCell : UITableViewCell
@property(nonatomic,assign)BOOL checkStated;
-(void)loadDataWithimageUrlArr:(NSArray*)imageUrlArr imageInfoArr:(NSArray*)imageInfoArr imageDateInfos:(NSArray*)imageDateInfos indexPath:(NSIndexPath*)indexPath;
-(void)checkStated:(BOOL)ischecked;
@end
