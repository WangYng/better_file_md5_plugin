// FlutterPlugin.ets
// better_file_md5_plugin
// Created by 汪洋 on 2024/12/19.

import common from '@ohos.app.ability.common';
import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import {
  AbilityPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import BasicMessageChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import EventChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import { Any, EventSink } from '@ohos/flutter_ohos';

const TAG: string = "BetterFileMd5Plugin";

export class Messages {
  static wrapError(exception: Error): Map<String, Any> {
    const errorMap: Map<String, Any> = new Map<String, Any>();
    errorMap['code'] = null;
    errorMap['message'] = exception.message;
    errorMap['details'] = null;
    return errorMap;
  }
}

export abstract class BetterFileMd5PluginApi {
  abstract fileMd5(instanceId: number, filePath: string): void;

  static getCodec(): MessageCodec<ESObject> {
    return new StandardMessageCodec();
  }

  static setup(binaryMessenger: BinaryMessenger, api: BetterFileMd5PluginApi) {
    // Method Channel for fileMd5
    const channel: BasicMessageChannel<Any> =
      new BasicMessageChannel<Any>(
        binaryMessenger,
        "io.github.wangyng.better_file_md5_plugin.fileMd5",
        BetterFileMd5PluginApi.getCodec());
    if (api != null) {
      channel.setMessageHandler({
        onMessage: (message: Any, reply: Any) => {
          let wrapped: Map<String, Any> = new Map<String, Any>();
          try {
            const args: Map<String, Any> = message as Map<String, Any>;

            const instanceId: number = args.get('instanceId') as number;
            const filePath: string = args.get('filePath') as string;
            api.fileMd5(instanceId, filePath);
            wrapped['result'] = null;
          } catch (err) {
            const wrappedError: Map<String, Any> = Messages.wrapError(err);
            wrapped['error'] = wrappedError;
          }
          reply.reply(wrapped);
        }
      })
    } else {
      channel.setMessageHandler(null);
    }
  }
}

export default class BetterFileMd5Plugin extends BetterFileMd5PluginApi implements FlutterPlugin, AbilityAware {
  private pluginBinding: FlutterPluginBinding | null = null;
  private context: common.Context | null = null;
  private eventChannel: EventChannel | null = null;
  private eventSink: EventSink | null = null;

  constructor(context?: common.Context) {
    super();
    if (context) {
      this.context = context;
    }
  }

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = binding;
    if (this.pluginBinding) {
      this.setup(this.pluginBinding.getBinaryMessenger(), this.pluginBinding.getApplicationContext());
    }
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
  }

  onDetachedFromAbility(): void {
  }

  static registerWith(): void {
  }

  setup(messenger: BinaryMessenger, context: common.Context) {
    try {
      BetterFileMd5PluginApi.setup(messenger, this);

      // Setup Event Channel
      this.eventChannel = new EventChannel(messenger, "io.github.wangyng.better_file_md5_plugin/resultStream");
      this.eventChannel.setStreamHandler({
        onListen: (args: Any, events: EventSink) => {
          this.eventSink = events;
        },
        onCancel: (args: Any) => {
          this.eventSink = null;
        }
      });
    } catch (err) {
      Log.e(TAG, "Received exception while setting up BetterFileMd5Plugin", err);
    }
    this.context = context;
  }

  fileMd5(instanceId: number, filePath: string): void {
    // This will be implemented by the actual plugin class
    Log.i(TAG, `fileMd5 called with instanceId: ${instanceId}, filePath: ${filePath}`);
  }

  protected emitResult(instanceId: number, md5?: string, error?: string): void {
    if (this.eventSink) {
      const result: Any = {
        instanceId: instanceId
      };
      if (md5) {
        result.md5 = md5;
      }
      if (error) {
        result.error = error;
      }
      this.eventSink.success(result);
    }
  }
}
