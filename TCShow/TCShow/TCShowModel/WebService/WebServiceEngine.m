//
//  WebServiceEngine.m
//
//
//  Created by Alexi on 14-8-5.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import "WebServiceEngine.h"

#import "BaseRequest.h"

#import "NSString+Common.h"
#import "HUDHelper.h"
#import "JSONKit.h"

#import "NetworkUtility.h"


#define kRequestTimeOutTime 30
#define kRequestError_Str @"请求出错"


@implementation WebServiceEngine

static WebServiceEngine *_sharedEngine = nil;

- (void)asyncRequest:(BaseRequest *)req
{
    [self asyncRequest:req wait:YES];
}

- (void)asyncRequest:(BaseRequest *)req wait:(BOOL)wait
{
    [self asyncRequest:req loadingMessage:nil wait:wait];
}


+ (instancetype)sharedEngine
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedEngine = [[WebServiceEngine alloc] init];
    });
    return _sharedEngine;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _sharedSession = [NSURLSession sharedSession];
    }
    return self;
}


- (void)asyncRequest:(BaseRequest *)req loadingMessage:(NSString *)msg wait:(BOOL)wait
{
    
    if (!req)
    {
        return;
    }
    
    //    if (![[NetworkUtility sharedNetworkUtility] isReachable])
    //    {
    //        [[HUDHelper sharedInstance] tipMessage:@"网络异常"];
    //        if (req.failHandler)
    //        {
    //            req.failHandler(req);
    //        }
    //        return;
    //    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *url = [req url];
        NSData *data = [req toPostJsonData];
        
        if ([NSString isEmpty:url])
        {
            DebugLog(@"[%@]请求出错了", [req class]);
            return;
        }
        
        DebugLog(@"reqest url = %@", url);
    
        NSURL *URL = [NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        
        if (data)
        {
            [request setValue:[NSString stringWithFormat:@"%ld",(long)[data length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            
            [request setHTTPBody:data];        
        }
        
        [request setTimeoutInterval:kRequestTimeOutTime];
        
        if (wait)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [NSString isEmpty:msg] ? [[HUDHelper sharedInstance] syncLoading] : [[HUDHelper sharedInstance] syncLoading:msg];
            });
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        
        NSURLSessionDataTask *task = [_sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (wait)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[HUDHelper sharedInstance] syncStopLoading];
                });
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if (error != nil)
            {
                DebugLog(@"Request = %@, Error = %@", req, error);
                
                
                if (req.failHandler)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        req.failHandler(req);
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[HUDHelper sharedInstance] tipMessage:kRequestError_Str];
                    });
                }
            }
            else
            {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                DebugLog(@"[%@] request's responseString is :\n================================\n %@ \n================================" , [req class], responseString);
                NSObject *jsonObj = [responseString objectFromJSONString];
                if (jsonObj)
                {
                    [req parseResponse:jsonObj];
                }
                else
                {
                    
                    DebugLog(@"请求出错");
                    if (req.failHandler)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            req.response.errorCode = -1;
                            req.response.errorInfo = @"返回数据非Json格式";
                            req.failHandler(req);
                        });
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[HUDHelper sharedInstance] tipMessage:kRequestError_Str];
                        });
                    }
                }
            }
        }];
        
        [task resume];
    });
}

@end

