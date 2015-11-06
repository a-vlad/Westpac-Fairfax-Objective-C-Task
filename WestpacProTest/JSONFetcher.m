    //
//  JSONFetcher.m
//  WestpacProTest
//
//  Created by Vlad P on 23/09/2014.
//  Copyright (c) 2014 VladSoftware. All rights reserved.
//

#import "JSONFetcher.h"
#import "Article.h"


@interface JSONFetcher() {
    NSMutableData* _receivedData;
    NSURLConnection* _connection;
}

@end


@implementation JSONFetcher

- (id)init
{
    self = [super init];
    if (self) {
        _receivedData = [[NSMutableData alloc] init];
    }
    return self;
}



#pragma mark - Class methods
- (void) fetchJSONArticlesFrom:(NSString *) urlPath{
    NSLog(@"\n\nPreparing to download: %@ ...",urlPath);
    
    [self closeConnection]; // In case already in the middle of a connection
    
    NSURL *downloadURL = [NSURL URLWithString:urlPath];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:CONNECTION_TIMEOUT];
    
    // Establish connection
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (_connection){
        NSLog(@"JSON Downloader: Connection Successful");
    }else{
        NSLog(@"JSON Downloader: Connection Failed");
        // Inform registered delegate of downloader failure
        if([[self delegate] respondsToSelector:@selector(gotJSONResponse:response:)]) {
            [[self delegate] gotJSONResponse:nil response:FetcherDownloadFailed];
        }
    }
}



- (void) closeConnection {
    NSLog(@"JSON Downloader: Connection Closed");
    
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
    NSLog(@"JSON Downloader: Connection complete successfully");
    
    // Finished downloading JSON we can close connection
    [self closeConnection];
    
    // Serialize JSON string
    NSError *err = nil;
    NSMutableArray *articleArray = nil;
    NSDictionary *serializedJson = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:_receivedData
                                                                                   options:NSJSONReadingMutableContainers
                                                                                     error:&err];
    
    if (serializedJson) {
        articleArray = [NSMutableArray new];
        NSDateFormatter *dateFormat = [NSDateFormatter new];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];  // eg 2014-09-23T11:08:21+10:00
        
        NSDictionary *jsonItems = [serializedJson objectForKey:@"items"];
        for (NSDictionary *item in jsonItems) {
            Article *tmpArticle = [Article new];

            NSDate *date = [dateFormat dateFromString:[item objectForKey:@"dateLine"]];
            [tmpArticle setDate: date];
            [tmpArticle setArticleID:(int)[item objectForKey:@"identifier"]];
            [tmpArticle setType:        [item objectForKey:@"type"]];
            [tmpArticle setHeadLine:    [item objectForKey:@"headLine"]];
            [tmpArticle setSlugLine:    [item objectForKey:@"slugLine"]];
            [tmpArticle setWebURL:      [item objectForKey:@"webHref"]];
            NSString *thumbUrl = [item objectForKey:@"thumbnailImageHref"];
            if ([thumbUrl isKindOfClass:[NSNull class]] ||
                [thumbUrl isEqualToString:@""])
            {
                [tmpArticle setThumbnailURL:nil];
            } else {
                [tmpArticle setThumbnailURL:thumbUrl];
            }
            [articleArray addObject:tmpArticle];
            
            [tmpArticle release];
        }
        [dateFormat release];
        
        // Inform registered delegate of downloader result
        if([[self delegate] respondsToSelector:@selector(gotJSONResponse:response:)]) {
            [[self delegate] gotJSONResponse:articleArray response:FetcherDownloadOk];
        }
        
        [articleArray release];
    } else {
        NSLog(@"Error parsing JSON: %@", err);
        // Inform registered delegate of downloader failure
        if([[self delegate] respondsToSelector:@selector(gotJSONResponse:response:)]) {
            [[self delegate] gotJSONResponse:nil response:FetcherDownloadFailed];
        }
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // inform the user
    NSLog(@"JSON Downloader: Connection Failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [self closeConnection];
    
    // Inform registered delegate of downloader failure
    if([[self delegate] respondsToSelector:@selector(gotJSONResponse:response:)]) {
        [[self delegate] gotJSONResponse:nil response:FetcherDownloadFailed];
    }
}



- (void) dealloc {
    [_receivedData release];
    [_connection release];
    [super dealloc];
}



@end
