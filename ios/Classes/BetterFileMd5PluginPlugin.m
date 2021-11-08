//
//  BetterFileMd5PluginPlugin.m
//  Pods
//
//  Created by 汪洋 on 2021/11/8.
//

#import "BetterFileMd5PluginPlugin.h"
#import "BetterFileMd5PluginEventSink.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface BetterFileMd5PluginPlugin()

@property (nonatomic, strong) BetterFileMd5PluginEventSink *resultStream;

@end

@interface NSData (Base64)
- (NSString *)base64Encode;
@end

@implementation BetterFileMd5PluginPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    BetterFileMd5PluginPlugin* instance = [[BetterFileMd5PluginPlugin alloc] init];
    [BetterFileMd5PluginApi setup:registrar api:instance];
}

- (void)setResultStream:(BetterFileMd5PluginEventSink *)resultStream {
    _resultStream = resultStream;
}

- (void)fileMd5WithInstanceId:(NSInteger)instanceId filePath:(NSString *)filePath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSMutableData *md5 = [BetterFileMd5PluginPlugin fileMd5WithFilePath:filePath];
        
        // 切换到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 返回结果
            if (md5 != nil) {
                NSString *base64Md5 = [[NSData dataWithData:md5] base64Encode];
                if (self.resultStream.event != nil) {
                    self.resultStream.event(@{@"instanceId": @(instanceId), @"md5": base64Md5});
                }
            } else {
                if (self.resultStream.event != nil) {
                    self.resultStream.event(@{@"instanceId": @(instanceId)});
                }
            }
        });
    });
}

+ (NSMutableData *)fileMd5WithFilePath:(NSString *)filePath {
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handle == nil) {
        return nil;
    }
    unsigned int length = 32 * 1024;
    NSMutableData *result = [NSMutableData dataWithLength:CC_MD5_DIGEST_LENGTH];
    CC_MD5_CTX context;
    CC_MD5_Init(&context);
    BOOL done = NO;
    while (!done) {
        @autoreleasepool {
            NSData* fileData = [handle readDataOfLength:length];
            CC_MD5_Update(&context, [fileData bytes], (unsigned int)[fileData length]);
            if( [fileData length] == 0 ) done = YES;
        }
    }
    CC_MD5_Final([result mutableBytes], &context);
    [handle closeFile];
    
    return result;
}

@end


@implementation NSData (Base64)

- (NSString *)base64Encode
{
    uint8_t* input = (uint8_t*)[self bytes];
    NSInteger length = [self length];
    
    if (!length) {
        return @"";
    }
    
    char* output = malloc(1 + ((length + 2) / 3) * 4);
    char* ptr = output;
    
    for (int i = 0; i < length; i += 3) {
        uint8_t src1, src2, src3;
        
        src1 = input[i];
        src2 = (i + 1 < length) ? input[i + 1] : 0;
        src3 = (i + 2 < length) ? input[i + 2] : 0;
        
        uint8_t dest1, dest2, dest3, dest4;
        
        dest1 = src1 >> 2;
        dest2 = ((src1 & 0x3) << 4) | (src2 >> 4);
        dest3 = ((src2 & 0xF) << 2) | (src3 >> 6);
        dest4 = src3 & 0x3F;
        
        *ptr++ = ByteEncode(dest1);
        *ptr++ = ByteEncode(dest2);
        *ptr++ = (i + 1 < length) ? ByteEncode(dest3) : '=';
        *ptr++ = (i + 2 < length) ? ByteEncode(dest4) : '=';
    }
    
    *ptr++ = 0;
    
    NSString *result = [[NSString alloc] initWithCString:output encoding:NSASCIIStringEncoding];
    free(output);
    
    return result ;
}

static char ByteEncode(uint8_t byte)
{
    if (byte < 26) {
        return 'A' + byte;
    }
    if (byte < 52) {
        return 'a' + (byte - 26);
    }
    if (byte < 62) {
        return '0' + (byte - 52);
    }
    if (byte == 62) {
        return '+';
    }
    
    return '/';
}

@end
