package io.github.wangyng.better_file_md5_plugin;

import android.content.Context;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.StandardMessageCodec;

public interface BetterFileMd5PluginApi {

    void setResultStream(Context context, BetterFileMd5PluginEventSink resultStream);

    void fileMd5(Context context, int instanceId, String filePath);

    static void setup(FlutterPlugin.FlutterPluginBinding binding, BetterFileMd5PluginApi api, Context context) {
        BinaryMessenger binaryMessenger = binding.getBinaryMessenger();

        {
            EventChannel eventChannel = new EventChannel(binaryMessenger, "io.github.wangyng.better_file_md5_plugin/resultStream");
            BetterFileMd5PluginEventSink eventSink = new BetterFileMd5PluginEventSink();
            if (api != null) {
                eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink.event = events;
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink.event = null;
                    }
                });
                api.setResultStream(context, eventSink);
            } else {
                eventChannel.setStreamHandler(null);
            }
        }

        {
            BasicMessageChannel<Object> channel = new BasicMessageChannel<>(binaryMessenger, "io.github.wangyng.better_file_md5_plugin.fileMd5", new StandardMessageCodec());
            if (api != null) {
                channel.setMessageHandler((message, reply) -> {
                    Map<String, Object> wrapped = new HashMap<>();
                    try {
                        HashMap<String, Object> params = (HashMap<String, Object>) message;
                        int instanceId = (int)params.get("instanceId");
                        String filePath = (String)params.get("filePath");
                        api.fileMd5(context, instanceId, filePath);
                        wrapped.put("result", null);
                    } catch (Exception exception) {
                        wrapped.put("error", wrapError(exception));
                    }
                    reply.reply(wrapped);
                });
            } else {
                channel.setMessageHandler(null);
            }
        }

   }

    static HashMap<String, Object> wrapError(Exception exception) {
        HashMap<String, Object> errorMap = new HashMap<>();
        errorMap.put("message", exception.toString());
        errorMap.put("code", null);
        errorMap.put("details", null);
        return errorMap;
    }
}
