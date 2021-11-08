//
//  BetterFileMd5PluginApi.m
//  Pods
//
//  Created by 汪洋 on 2021/11/8.
//

#import "BetterFileMd5PluginApi.h"

@implementation BetterFileMd5PluginApi

+ (void)setup:(NSObject<FlutterPluginRegistrar> *)registrar api:(id<BetterFileMd5PluginApiDelegate>)api {
    NSObject<FlutterBinaryMessenger> *messenger = [registrar messenger];

    {
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"io.github.wangyng.better_file_md5_plugin/resultStream" binaryMessenger:messenger];
        BetterFileMd5PluginEventSink *eventSink = [[BetterFileMd5PluginEventSink alloc] init];
        if (api != nil) {
            [eventChannel setStreamHandler:eventSink];
            [api setResultStream:eventSink];
        }
    }

    {
        FlutterBasicMessageChannel *channel =[FlutterBasicMessageChannel messageChannelWithName:@"io.github.wangyng.better_file_md5_plugin.fileMd5" binaryMessenger:messenger];
        if (api != nil) {
            [channel setMessageHandler:^(id  message, FlutterReply reply) {
                NSMutableDictionary<NSString *, NSObject *> *wrapped = [NSMutableDictionary new];
                if ([message isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *params = message;
                    NSInteger instanceId = [params[@"instanceId"] integerValue];
                    NSString *filePath = params[@"filePath"];
                    [api fileMd5WithInstanceId:instanceId filePath:filePath];
                    wrapped[@"result"] = nil;
                } else {
                    wrapped[@"error"] = @{@"message": @"parse message error"};
                }
                reply(wrapped);
            }];
        } else {
            [channel setMessageHandler:nil];
        }
    }

}

@end
