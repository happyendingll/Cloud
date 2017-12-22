//
//  PhotoCollectionViewCell.m
//  Cloud
//
//  Created by 曾志远 on 2017/12/13.
//  Copyright © 2017年 曾志远. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imagev];
        [self addSubview:self.deleteButton];
    }
    return self;
}

-(UIImageView*)imagev{
    if (!_imagev) {
        _imagev=[[UIImageView alloc]initWithFrame:self.bounds];
    }
    return _imagev;
}
-(UIButton*)deleteButton{
    if (!_deleteButton) {
        _deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-20, 0, 20, 20)];
        [_deleteButton setBackgroundImage:[UIImage imageNamed:@"photo_delete"] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

@end
