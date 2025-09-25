// BetterFileMd5Plugin.ets
// better_file_md5_plugin
// Created by 汪洋 on 2024/12/19.

import { fileIo } from '@kit.CoreFileKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';
import { Any } from '@ohos/flutter_ohos';
import BetterFileMd5PluginBase from './FlutterPlugin';
import common from '@ohos.app.ability.common';

const TAG = 'BetterFileMd5Plugin';

export default class BetterFileMd5Plugin extends BetterFileMd5PluginBase {
  private static instance: BetterFileMd5Plugin;

  constructor(context?: common.Context) {
    super(context);
  }

  public static getInstance(context?: Any): BetterFileMd5Plugin {
    if (!BetterFileMd5Plugin.instance) {
      BetterFileMd5Plugin.instance = new BetterFileMd5Plugin(context);
    }
    return BetterFileMd5Plugin.instance;
  }

  public fileMd5(instanceId: number, filePath: string): void {
    // 异步计算MD5
    this.calculateFileMd5Async(instanceId, filePath);
  }

  private async calculateFileMd5Async(instanceId: number, filePath: string): Promise<void> {
    try {
      const md5 = await this.calculateFileMd5(filePath);
      this.emitResult(instanceId, md5);
    } catch (error) {
      this.emitResult(instanceId, undefined, error.message);
    }
  }

  private async calculateFileMd5(filePath: string): Promise<string> {
    try {
      // 创建MD5实例
      const md = cryptoFramework.createMd('MD5');
      if (!md) {
        throw new Error('Failed to create MD5 algorithm');
      }

      // 打开文件
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
      if (!file) {
        throw new Error('File not found');
      }

      const arrayBuffer = new ArrayBuffer(2048);
      let len: number;
      let position = 0;

      // 分块读取文件内容
      do {
        len = fileIo.readSync(file.fd, arrayBuffer, { offset: position });
        if (len > 0) {
          const uint8Array = new Uint8Array(arrayBuffer.slice(0, len));
          await md.update({ data: uint8Array }); // 更新MD5计算
          position += len;
        }
      } while (len > 0);

      // 关闭文件并获取最终结果
      fileIo.closeSync(file.fd);
      const mdResult = await md.digest();

      // 转换为十六进制字符串
      const hexMd5 = buffer.from(mdResult.data).toString('hex');
      return hexMd5;
    } catch (error) {
      throw new Error('Error in calculateFileMd5');
    }
  }
}