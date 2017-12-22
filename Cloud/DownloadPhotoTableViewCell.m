//
//  DownloadPhotoTableViewCell.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/15.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "DownloadPhotoTableViewCell.h"
#import <UIImageView+WebCache.h>//导入缓存图片框架
@interface DownloadPhotoTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *imageInfo;
@property (weak, nonatomic) IBOutlet UILabel *imageDateInfo;
@property (weak, nonatomic) IBOutlet UIImageView *checkImage;


@end
@implementation DownloadPhotoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)loadDataWithimageUrlArr:(NSArray*)imageUrlArr imageInfoArr:(NSArray*)imageInfoArr imageDateInfos:(NSArray*)imageDateInfos indexPath:(NSIndexPath*)indexPath{
    [self.imageV sd_setImageWithURL:[imageUrlArr objectAtIndex:indexPath.row] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority];
    self.imageV.contentMode=UIViewContentModeScaleAspectFill;
    self.imageV.clipsToBounds=YES;
    self.imageInfo.text=imageInfoArr[indexPath.row];
    //self.imageInfo.textColor=[UIColor blackColor];
    self.imageDateInfo.text=imageDateInfos[indexPath.row];
}
-(void)checkStated:(BOOL)ischecked{
    self.checkStated=ischecked;
    if (self.checkStated) {
        self.checkImage.image=[UIImage imageNamed:@"select"];
    }else{
        self.checkImage.image=[UIImage imageNamed:@"unselected"];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.backgroundColor=[UIColor clearColor];
    // Configure the view for the selected state
}

@end
