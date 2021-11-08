package io.github.wangyng.better_file_md5_plugin;

import android.content.Context;
import android.os.Handler;
import android.util.Base64;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class BetterFileMd5PluginPlugin implements FlutterPlugin, BetterFileMd5PluginApi {

    BetterFileMd5PluginEventSink resultStream;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        BetterFileMd5PluginApi.setup(binding, this, binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        BetterFileMd5PluginApi.setup(binding, null, null);
    }


    @Override
    public void setResultStream(Context context, BetterFileMd5PluginEventSink resultStream) {
        this.resultStream = resultStream;
    }

    @Override
    public void fileMd5(Context context, int instanceId, String filePath) {
        new Thread(() -> {
            String md5 = BetterFileMd5PluginPlugin.fileMd5(filePath);

            // 切换到主线程
            Handler handler = new Handler(context.getMainLooper());
            handler.post(() -> {
                if (resultStream != null) {
                    // 返回结果
                    Map<String, Object> result = new HashMap<>();
                    result.put("instanceId", instanceId);
                    result.put("md5", md5);
                    resultStream.event.success(result);
                }
            });

        }).start();

    }

    /// 获取文件md5
    private static String fileMd5(String filePath) {
        String md5 = null;
        File file = new File(filePath);
        if (file.exists()) {
            InputStream inputStream = null;
            try {
                MessageDigest messageDigest = MessageDigest.getInstance("MD5");
                byte[] buffer = new byte[1024 * 8];

                inputStream = new FileInputStream(file);
                int numRead;
                while ((numRead = inputStream.read(buffer)) != -1) {
                    messageDigest.update(buffer, 0, numRead);
                }
                byte[] digest = messageDigest.digest();
                md5 = new String(Base64.encode(digest, Base64.DEFAULT)).trim();
            } catch (Exception e) {
                if (inputStream != null) {
                    try {
                        inputStream.close();
                    } catch (IOException ioException) {
                        ioException.printStackTrace();
                    }
                }
            }
        }
        return md5;
    }

}
