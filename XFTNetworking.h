//
//  XFTNetworking.h
//  XinFangTongHK
//
//  Created by QFWangLP on 16/3/29.
//  Copyright © 2016年 qfang. All rights reserved.
//  仅支持7.0以上版本--结合系统新的api-NSURLSessionTask

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  下载进度
 *
 *  @param bytesRead      已下载的字节数
 *  @param totalBytesRead 下载文件总大小
 */
typedef void(^XFTDownloadProgress)(int64_t bytesRead,int64_t totalBytesRead);

typedef XFTDownloadProgress XFTGetProgress;
typedef XFTDownloadProgress XFTPostProgress;

/**
 *  上传进度
 *
 *  @param bytesWritten      已上传文件大小
 *  @param totalBytesWritten 总上传文件大小
 */
typedef void(^XFTUploadProgress)(int64_t bytesWritten, int64_t totalBytesWritten);
typedef XFTUploadProgress XFTUploadGetProgress;
typedef XFTUploadProgress XFTUploadPostProgress;

typedef NS_ENUM(NSUInteger,XFTResponseType) {
    XFTResponseTypeJSON = 1, //默认JSON
    XFTResponseTypeXML  = 2, //XML
    // 特殊情况下，一转换服务器就无法识别的，默认会尝试转换成JSON，若失败则需要自己去转换
    XFTResponseTypeDate = 3
};

typedef NS_ENUM(NSUInteger,XFTRequestType) {
    XFTRequestTypeJSON = 1,     //默认
    XFTRequestTypePlainText = 2 //普通text/html
};

@class NSURLSessionTask;

// 请勿直接使用NSURLSessionDataTask,以减少对第三方的依赖
// 所有接口返回的类型都是基类NSURLSessionTask，若要接收返回值
// 且处理，请转换成对应的子类类型
typedef NSURLSessionTask XFTURLSessionTask;

/**
 *  请求成功回调
 *
 *  @param response 服务器返回的数据类型,通常是JSON
 */
typedef void(^XFTResponseSuccess)(id response);

/**
 *  请求失败回调
 *
 *  @param error 返回错误信息
 */
typedef void(^XFTResponseFailure)(NSError *error);

@interface XFTNetworking : NSObject

@property (nonatomic, copy) XFTUploadProgress uploadProgress;
/**
 *  用于指定网络请求接口的基础url，如：
 *  通常在AppDelegate中启动时就设置一次就可以了。如果接口有来源
 *  于多个服务器，可以调用更新
 *
 *  @param baseUrl 网络请求的基础Url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;

/**
 *  对外公开可获取当前所设置的网络接口基础url
 *
 *  @return 当前的基础url
 */
+ (NSString *)baseUrl;

/**
 *  开启或关闭打印调用网络接口信息
 *
 *  @param isDebug 开发期间，最好打开，默认是NO
 */
+ (void)enableInterfaceDebug:(BOOL)isDebug;

/**
 *  配置返回格式，默认为JSON。若为XML或者PLIST请在全局修改一下
 *
 *  @param responseType 响应格式
 */
+ (void)configResponseType:(XFTResponseType)responseType;

/**
 *  配置请求格式，默认为JSON。如果要求传XML或者PLIST，请在全局配置一下
 *
 *  @param requestType 请求格式
 */
+ (void)configRequestType:(XFTRequestType)requestType;

/**
 *  开启或关闭是否自动将URL使用UTF8编码，用于处理链接中有中文时无法请求的问题
 *
 *  @param shouldAutoEncode YES or NO,默认为NO
 */
+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode;

/**
 *  配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了
 *
 *  @param httpHeaders 只需要将与服务器商定的固定参数设置即可
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;


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
                          failure:(XFTResponseFailure)failure;

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
                          failure:(XFTResponseFailure)failure;

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
                          failure:(XFTResponseFailure)failure;




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
                          failure:(XFTResponseFailure)failure;

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
                          failure:(XFTResponseFailure)failure;

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
                               failure:(XFTResponseFailure)failure;
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
                                 failure:(XFTResponseFailure)failure;

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
                               failure:(XFTResponseFailure)failure;
@end
