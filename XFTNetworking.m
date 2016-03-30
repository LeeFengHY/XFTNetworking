//
//  XFTNetworking.m
//  XinFangTongHK
//
//  Created by QFWangLP on 16/3/29.
//  Copyright © 2016年 qfang. All rights reserved.
//

#import "XFTNetworking.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPSessionManager.h"

// 项目打包上线都不会打印日志，因此可放心。
#ifdef DEBUG
#define XFTAppLog(s, ... ) NSLog( @"[%@：in line: %d]-->%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define XFTAppLog(s, ... )
#endif
/**
 *  定义部分变量初始值
 */
static NSString *xft_networkBaseUrl = nil;
static BOOL      xft_isEnableInterfaceDebug = NO;
static BOOL      xft_shouldAutoEncode = NO;
static NSDictionary * xft_httpheaders = nil;
static XFTResponseType xft_responseType = XFTResponseTypeJSON;
static XFTRequestType xft_requestType  = XFTRequestTypeJSON;

@implementation XFTNetworking

/**
 *  用于指定网络请求接口的基础url，如：
 *  通常在AppDelegate中启动时就设置一次就可以了。如果接口有来源
 *  于多个服务器，可以调用更新
 *
 *  @param baseUrl 网络请求的基础Url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl
{
    xft_networkBaseUrl = baseUrl;
}

/**
 *  对外公开可获取当前所设置的网络接口基础url
 *
 *  @return 当前的基础url
 */
+ (NSString *)baseUrl
{
    return xft_networkBaseUrl;
}

/**
 *  开启或关闭打印调用网络接口信息
 *
 *  @param isDebug 开发期间，最好打开，默认是NO
 */
+ (void)enableInterfaceDebug:(BOOL)isDebug
{
    xft_isEnableInterfaceDebug = isDebug;
}

+ (BOOL)isDebug
{
    return xft_isEnableInterfaceDebug;
}
/**
 *  配置返回格式，默认为JSON。若为XML或者PLIST请在全局修改一下
 *
 *  @param responseType 响应格式
 */
+ (void)configResponseType:(XFTResponseType)responseType
{
    xft_responseType = responseType;
}

/**
 *  配置请求格式，默认为JSON。如果要求传XML或者PLIST，请在全局配置一下
 *
 *  @param requestType 请求格式
 */
+ (void)configRequestType:(XFTRequestType)requestType
{
    xft_requestType = requestType;
}

/**
 *  开启或关闭是否自动将URL使用UTF8编码，用于处理链接中有中文时无法请求的问题
 *
 *  @param shouldAutoEncode YES or NO,默认为NO
 */
+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
{
    xft_shouldAutoEncode = shouldAutoEncode;
}

+ (BOOL)shouldEncode
{
    return xft_shouldAutoEncode;
}
/**
 *  配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了
 *
 *  @param httpHeaders 只需要将与服务器商定的固定参数设置即可
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders
{
    xft_httpheaders = httpHeaders;
}

/**
 *  GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径:  如/path/getHouseList?bizType=sale
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (XFTURLSessionTask *)getWithUrl:(NSString *)url
                          success:(XFTResponseSuccess)success
                          failure:(XFTResponseFailure)failure
{
    return [self getWithUrl:url params:nil success:success failure:failure];
}

/**
 *  GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路:  如/path/getHouseList?bizType=sale
 *  @param params  接口中所需要的拼接参数，如@{"keyword" : @"龙华"}
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (XFTURLSessionTask *)getWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                          success:(XFTResponseSuccess)success
                          failure:(XFTResponseFailure)failure
{
    return [self getWithUrl:url params:params progress:nil success:success failure:failure];
}

/**
 *  GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路:  如/path/getHouseList?bizType=sale
 *  @param params  接口中所需要的拼接参数，如@{"keyword" : @"龙华"}
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 *  @param progress 下载文件进度
 *  @return 返回的对象中有可取消请求的API
 */
+ (XFTURLSessionTask *)getWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                         progress:(XFTGetProgress)progress
                          success:(XFTResponseSuccess)success
                          failure:(XFTResponseFailure)failure
{
    return [self requestWithUrl:url httpMethod:1 params:params progress:progress success:success failure:failure];
}




/**
 *  POST请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路:  如/path/getHouseList?bizType=sale
 *  @param params  接口中所需要的拼接参数，如@{"keyword" : @"龙华"}
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (XFTURLSessionTask *)postWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                           success:(XFTResponseSuccess)success
                           failure:(XFTResponseFailure)failure
{
    return [self postWithUrl:url params:params progress:nil success:success failure:failure];
}

/**
 *  POST请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路:  如/path/getHouseList?bizType=sale
 *  @param params  接口中所需要的拼接参数，如@{"keyword" : @"龙华"}
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (XFTURLSessionTask *)postWithUrl:(NSString *)url
                            params:(NSDictionary *)params
                          progress:(XFTPostProgress)progress
                           success:(XFTResponseSuccess)success
                           failure:(XFTResponseFailure)failure
{
    return [self requestWithUrl:url httpMethod:2 params:params progress:progress success:success failure:failure];
}

/**
 *  图片上传接口，若不指定baseurl，可传完整的url
 *
 *  @param image      图片对象
 *  @param url        上传图象路径
 *  @param fileName   给图片起一个名字，默认为当前日期时间,格式为"yyyyMMddHHmmss"，后缀为`jpg`
 *  @param name       与指定的图片相关联的名称，这是由后端写接口的人指定的，如imagefiles
 *  @param mimeType   默认为image/jpeg
 *  @param parameters 参数
 *  @param progress   上传进度
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (XFTURLSessionTask *)uploadWithImage:(UIImage *)image
                                   url:(NSString *)url
                              fileName:(NSString *)fileName
                                  name:(NSString *)name
                              mimeType:(NSString *)mimeType
                            parameters:(NSDictionary *)parameters
                              progress:(XFTUploadProgress)progress
                               success:(XFTResponseSuccess)success
                               failure:(XFTResponseFailure)failure
{
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            XFTAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            XFTAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    AFHTTPSessionManager *manager = [self manager];
    NSProgress *uploadProgress = nil;
    XFTURLSessionTask *session = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        NSString *imageFileName = fileName;
        if (fileName == nil || ![fileName isKindOfClass:[NSString class]] || fileName.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg",str];
        }
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:mimeType];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self successResponse:responseObject callback:success];
        
        if ([self isDebug]) {
            [self logWithSuccessResponse:responseObject
                                     url:task.response.URL.absoluteString
                                  params:parameters];
        }

         [uploadProgress removeObserver:(XFTNetworking *)self forKeyPath:@"fractionCompleted"];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
        if ([self isDebug]) {
            [self logWithFailError:error url:task.response.URL.absoluteString params:parameters];
        }
         [uploadProgress removeObserver:(XFTNetworking *)self forKeyPath:@"fractionCompleted"];
    }];
    // 给这个progress添加监听任务
    [uploadProgress addObserver:(XFTNetworking *)self
                     forKeyPath:@"fractionCompleted"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
    return session;
}
/**
 *  上传文件操作
 *
 *  @param url      上传文件接口
 *  @param filePath 上传文件路径
 *  @param progress 上传进度
 *  @param success  成功回调
 *  @param failure  失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (XFTURLSessionTask *)uploadFileWithUrl:(NSString *)url
                              uploadFile:(NSString *)filePath
                                progress:(XFTUploadProgress)progress
                                 success:(XFTResponseSuccess)success
                                 failure:(XFTResponseFailure)failure
{
    if ([NSURL URLWithString:filePath] == nil) {
        XFTAppLog(@"filePath无效，无法生成URL。请检查待上传文件是否存在");
        return nil;
    }
    
    NSURL *uploadURL = nil;
    if ([self baseUrl] == nil) {
        uploadURL = [NSURL URLWithString:url];
    }else{
        uploadURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[self baseUrl],url]];
    }
    
    if (uploadURL == nil) {
        XFTAppLog(@"URLString无效，无法生成URL。可能是URL中有中文或特殊字符，请尝试Encode URL");
        return nil;
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    AFHTTPSessionManager *manager = [self manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:uploadURL];
    NSProgress *uploadProgress = nil;
    XFTURLSessionTask *session = [manager uploadTaskWithRequest:request fromFile:[NSURL URLWithString:filePath] progress:&uploadProgress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        [self successResponse:responseObject callback:success];
        
        if (error) {
            if (failure) {
                failure(error);
            }
            
            if ([self isDebug]) {
                [self logWithFailError:error url:response.URL.absoluteString params:nil];
            }
        } else {
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:response.URL.absoluteString
                                      params:nil];
            }
        }

        [uploadProgress removeObserver:(XFTNetworking *)self forKeyPath:@"fractionCompleted"];
    }];
    
    // 给这个progress添加监听任务
    [uploadProgress addObserver:(XFTNetworking *)self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    return session;
}

+ (id)returnaddObserverSelf
{
    static XFTNetworking *networking = nil;
    if (networking == nil) {
        networking = [[self alloc] init];
    }
    return networking;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress is %f", progress.fractionCompleted);
        if (_uploadProgress) {
            _uploadProgress(progress.completedUnitCount,progress.totalUnitCount);
        }
        // 打印这个唯一标示符
        NSLog(@"%@", progress.userInfo);
    }
}

/**
 *  下载文件
 *
 *  @param url        下载URL
 *  @param saveToPath 下载到哪个路径下
 *  @param progress   下载进度
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (XFTURLSessionTask *)downloadWithUrl:(NSString *)url
                            saveToPath:(NSString *)saveToPath
                              progress:(XFTDownloadProgress)progress
                               success:(XFTResponseSuccess)success
                               failure:(XFTResponseFailure)failure
{
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            XFTAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            XFTAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    NSProgress *downloadProgress = nil;
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self manager];
    XFTURLSessionTask *session = [manager downloadTaskWithRequest:downloadRequest progress:&downloadProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL URLWithString:saveToPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (success) {
            success(filePath.absoluteString);
        }
        
        [downloadProgress removeObserver:(XFTNetworking *)self  forKeyPath:@"fractionCompleted"];
    }];
    
    [downloadProgress addObserver:(XFTNetworking *)self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    
    return session;
}

+ (XFTURLSessionTask *)requestWithUrl:(NSString *)url
                           httpMethod:(NSInteger)httpMthods
                               params:(NSDictionary *)params
                             progress:(XFTDownloadProgress)progress
                              success:(XFTResponseSuccess)success
                              failure:(XFTResponseFailure)failure
{
    AFHTTPSessionManager *manager = [self manager];
    
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            XFTAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }else{
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[self baseUrl],url]] == nil) {
            XFTAppLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return nil;
        }
    }
    
    if ([self shouldEncode]) {
        url = [self encodeUrl:url];
    }
    
    XFTURLSessionTask *session = nil;
    NSProgress *pgProgress = nil;
    
    if (httpMthods == 1) {
        session = [manager GET:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [self successResponse:responseObject callback:success];
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject url:task.response.URL.absoluteString params:params];
            }
            
            [pgProgress removeObserver:(XFTNetworking *)self  forKeyPath:@"fractionCompleted"];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failure) {
                failure(error);
            }
            if ([self isDebug]) {
                [self logWithFailError:error url:task.response.URL.absoluteString params:params];
            }
            
            [pgProgress removeObserver:(XFTNetworking *)self  forKeyPath:@"fractionCompleted"];
        }];
    }else if (httpMthods == 2){
        session = [manager POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [self successResponse:responseObject callback:success];
            if ([self isDebug]) {
                [self logWithSuccessResponse:responseObject
                                         url:task.response.URL.absoluteString
                                      params:params];
            }
            [pgProgress removeObserver:(XFTNetworking *)self  forKeyPath:@"fractionCompleted"];

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failure) {
                failure(error);
            }
            if ([self isDebug]) {
                [self logWithFailError:error url:task.response.URL.absoluteString params:params];
            }
            
            [pgProgress removeObserver:(XFTNetworking *)self  forKeyPath:@"fractionCompleted"];
        }];
    }
    [pgProgress addObserver:(XFTNetworking *)self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    return session;
}

+ (AFHTTPSessionManager *)manager
{
    //开启网络请求圈圈
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *session = nil;
    if ([self baseUrl] != nil) {
        session = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
    }else{
        session = [AFHTTPSessionManager manager];
    }
    
    switch (xft_requestType) {
        case XFTRequestTypeJSON:
        {
            session.requestSerializer = [AFJSONRequestSerializer serializer];
            [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
            break;
        case XFTRequestTypePlainText:
        {
            session.requestSerializer = [AFHTTPRequestSerializer serializer];
        }
            break;
            
        default:
            break;
    }
    
    switch (xft_responseType) {
        case XFTResponseTypeJSON:
        {
            session.responseSerializer = [AFJSONResponseSerializer serializer];
        }
            break;
        case XFTResponseTypeXML:
        {
            session.responseSerializer = [AFXMLParserResponseSerializer serializer];
        }
            break;
        case XFTResponseTypeDate:
        {
            session.responseSerializer = [AFHTTPResponseSerializer serializer];
        }
            break;
        default:
            break;
    }
    
    session.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    
    for (NSString *key in xft_httpheaders.allKeys) {
        if (xft_httpheaders[key] != nil) {
            [session.requestSerializer setValue:xft_httpheaders[key] forHTTPHeaderField:key];
        }
    }
    
    NSArray *acceptContentTypesArray = @[@"application/json",@"text/html",@"text/json",@"text/plain",@"text/javascript",@"text/xml",@"image/*"];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithArray:acceptContentTypesArray];
    
    // 设置允许同时最大并发数量，过大容易出问题
    session.operationQueue.maxConcurrentOperationCount = 3;
    return session;
}

+ (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params
{
    XFTAppLog(@"\n absoluteUrl: %@\n params: %@\n response: %@\n\n",[self generateGETAbsoluteURL:url params:params],params,[self tryToParseData:response]);
}

+ (void)logWithFailError:(NSError *)error url:(NSString *)url params:(NSDictionary *)params
{
    XFTAppLog(@"\n absoluteUrl: %@\n params: %@\n failureError: %@\n\n",[self generateGETAbsoluteURL:url params:params],params,[error localizedDescription]);
}

/**
 *  成功回调
 *
 *  @param responseData <#responseData description#>
 *  @param success      <#success description#>
 */
+ (void)successResponse:(id)responseData callback:(XFTResponseSuccess)success {
    if (success) {
        success([self tryToParseData:responseData]);
    }
}

+ (id)tryToParseData:(id)responseDate
{
    if ([responseDate isKindOfClass:[NSData class]]) {
        //尝试解析JSON
        if (responseDate == nil) {
            return responseDate;
        }else{
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseDate options:NSJSONReadingMutableContainers error:&error];
            if (error != nil) {
                return responseDate;
            }else{
                return response;
            }
        }
    }else{
        return responseDate;
    }
}

// 仅对一级字典结构起作用
+ (NSString *)generateGETAbsoluteURL:(NSString *)url params:(NSDictionary *)params {
    if (params.count == 0) {
        return url;
    }
    
    NSString *queries = @"";
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url rangeOfString:@"http://"].location != NSNotFound
         || [url rangeOfString:@"https://"].location != NSNotFound)
        && queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound
            || [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    
    return url.length == 0 ? queries : url;
}
/**
 *  url 带中文转换
 *
 *  @param url
 *
 *  @return
 */
+ (NSString *)encodeUrl:(NSString *)url {
    return [self xft_URLEncode:url];
}
+ (NSString *)xft_URLEncode:(NSString *)url
{
    NSString *newString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString) {
        return newString;
    }
    return url;
}
@end
