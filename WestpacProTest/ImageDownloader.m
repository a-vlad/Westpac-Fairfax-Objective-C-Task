//
//  ImageDownloader.m
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader() {
    NSMutableData* _receivedData;
    NSURLConnection* _connection;
}

@property (nonatomic, copy) void (^completionHandler)(UIImage *downloadedImage);
@end




@implementation ImageDownloader
@synthesize completionHandler = _completionHandler;


- (void) downloadImageFromUrl:(NSString*)urlPath withCompletionHandler:(void(^)(UIImage *downloadedImage))completionHandler {
    _receivedData = [[NSMutableData alloc] init];
    _completionHandler = [completionHandler copy];
    [self cancelDownload]; // In case already in the middle of a connection
    
    NSLog(@"\n\nPreparing to download image: %@ ...", urlPath);
    
    NSURL *downloadURL = [NSURL URLWithString:urlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:CONNECTION_TIMEOUT];
    
    // Establish connection
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (_connection){
        NSLog(@"Image Downloader: Connection Successful");
    } else {
        NSLog(@"Image Downloader: Connection Failed");
        if (_completionHandler) _completionHandler(nil);
    }
}

- (void) cancelDownload {
    [_connection cancel];
    [_connection release];
    _connection = nil;
}


#pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Clear received data in case it has already been filled up from previous request
    [_receivedData setLength:0];
}


// Receives the incoming data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Image Downloader: Connection complete successfully");
    
    UIImage *image = [[UIImage alloc] initWithData:_receivedData];
    
    CGSize scaleSize = CGSizeMake(90, 90);
    UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 0.0f);
    CGRect imageRect = CGRectMake(0.0, 0.0, scaleSize.width, scaleSize.height);
    [image drawInRect:imageRect];
    UIImage* resizedImg = UIGraphicsGetImageFromCurrentImageContext();
    
    if (_completionHandler) _completionHandler(resizedImg);
    
    UIGraphicsEndImageContext();

    [image release];
    
    [self cancelDownload];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Image Downloader: Connection Failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    if (_completionHandler) _completionHandler(nil);

    [self cancelDownload];
}

- (void) dealloc {
    [_receivedData release];
    [_connection release];
    [_completionHandler release];
    [super dealloc];
}

@end
