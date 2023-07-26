//
//  MERViewController.m
//  SDWebImageDemo
//
//  Created by Mervin1024 on 07/26/2023.
//  Copyright (c) 2023 Mervin1024. All rights reserved.
//

#import "MERViewController.h"
#import <SDWebImage/SDWebImage.h>

@interface MERImageCoder : SDImageCodersManager

@end

@implementation MERImageCoder

/// Simulates a long image decoding process
- (UIImage *)decodedImageWithData:(NSData *)data options:(SDImageCoderOptions *)options {
    sleep(2);
    return [super decodedImageWithData:data options:options];
}

@end

@interface MERViewController ()
@property (nonatomic, strong) UIImageView *firstImageView;
@property (nonatomic, strong) UIImageView *secondImageView;
@property (nonatomic, strong) NSURL *imageUrl;
@end

@implementation MERViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    
    self.imageUrl = [NSURL URLWithString:@"https://ts1.cn.mm.bing.net/th?id=ORMS.d50b1dea1f163120f6de16257c607c68&pid=Wdp&w=300&h=225&qlt=90&c=1&rs=1"];
    
    self.firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.firstImageView.backgroundColor = [UIColor systemGrayColor];
    self.firstImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.firstImageView];
    self.firstImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 200);
    
    self.secondImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.secondImageView.backgroundColor = [UIColor systemGrayColor];
    self.secondImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.secondImageView];
    self.secondImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + 200);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webImageDownloadStart:) name:SDWebImageDownloadStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webImageDownloadStop:) name:SDWebImageDownloadStopNotification object:nil];
    
    [self loadFirstImage];
}

- (void)loadFirstImage {
    NSLog(@"First image load begin");
    [self.firstImageView sd_setImageWithURL:self.imageUrl
                           placeholderImage:nil
                                    options:kNilOptions
                                    context:@{SDWebImageContextImageCoder: [[MERImageCoder alloc] init]}
                                   progress:nil
                                  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSLog(@"First image load finished: %@", @(cacheType));
    }];
}

- (void)webImageDownloadStart:(NSNotification *)notification {
    NSLog(@"Image start download: %p", notification.object);
}

- (void)webImageDownloadStop:(NSNotification *)notification {
    NSLog(@"Image stop download: %p", notification.object);
    /// The second image is loaded during the decoding of the first image
    /// and a second request will be opened for the same url
    if (!self.secondImageView.sd_imageURL) {
        NSLog(@"Second image load begin");
        [self.secondImageView sd_setImageWithURL:self.imageUrl
                                placeholderImage:nil
                                         options:kNilOptions
                                         context:@{SDWebImageContextImageCoder: [[MERImageCoder alloc] init]}
                                        progress:nil
                                       completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSLog(@"Second image load finished: %@", @(cacheType));
        }];
    }
}

@end
