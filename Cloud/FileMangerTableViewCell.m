//
//  FileMangerTableViewCell.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/22.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "FileMangerTableViewCell.h"
@interface FileMangerTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *fileIcon;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@end
@implementation FileMangerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)loadDataWithFileName:(NSString*)fileName{
    self.fileIcon.image=[UIImage imageNamed:@"folder"];
    self.fileName.text=fileName;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.backgroundColor=[UIColor clearColor];
    // Configure the view for the selected state
}

@end
