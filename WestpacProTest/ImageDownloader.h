//
//  ImageDownloader.h
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageDownloader : NSObject

- (void) downloadImageFromUrl:(NSString*)urlPath withCompletionHandler:(void(^)(UIImage *downloadedImage))completionHandler;
- (void) cancelDownload;

@end
