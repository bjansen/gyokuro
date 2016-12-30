import ceylon.http.server.websocket {
    WebSocketChannel,
    CloseReason
}
import ceylon.buffer {
    ByteBuffer
}
import net.gyokuro.core.internal {
    router
}


"A handler that can react to WebSocket events."
shared alias WSHandler => Anything(WebSocketChannel, String)|WebSocketHandler;

"A handler for WebSockets that reacts to advanced events."
shared abstract class WebSocketHandler() {
    shared default void onOpen(WebSocketChannel channel) {}

    shared default void onClose(WebSocketChannel channel, CloseReason closeReason) {}

    shared default void onError(WebSocketChannel channel, Throwable? throwable) {}

    shared default void onText(WebSocketChannel channel, String text) {}

    shared default void onBinary(WebSocketChannel channel, ByteBuffer binary) {}
}

"Registers a new web socket handler for the given [[path]]. The handler can be a simple
 'onText' function, or a more advanced [[WebSocketHandler]]."
// TODO use WSHandler when https://github.com/ceylon/ceylon/issues/6843 is fixed
shared void websocket(String path, WebSocketHandler|Anything(WebSocketChannel, String) handler)
        => router.registerWebSocketHandler(path, handler);