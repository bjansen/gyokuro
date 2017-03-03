---
layout: default
useToc: true
toc-start: 9
title: WebSockets
---

{% include toc.md %}

## {{page.title}}

WebSockets make it possible to open a persistent channel between a client and the
server, allowing both of them to send messages at any time, removing the need for
polling the server.

To open a websocket endpoint on the server, use the `websocket` function:

    websocket("/ws", (channel, text) => channel.sendText("Hello, ``text``!"));

This will bind the path `/ws` with a simple handler with two parameters: a channel and
the text that was sent by the client. To send a response, `channel.sendText` is used to
greet the client.

It is possible to use more advanced handlers that can react to events like "the connection
was open" or "the client sent binary data" by extending `WebSocketHandler`:

    shared abstract class WebSocketHandler() {
        shared default void onOpen(WebSocketChannel channel) {}

        shared default void onClose(WebSocketChannel channel, CloseReason closeReason) {}

        shared default void onError(WebSocketChannel channel, Throwable? throwable) {}

        shared default void onText(WebSocketChannel channel, String text) {}

        shared default void onBinary(WebSocketChannel channel, ByteBuffer binary) {}
    }

Note that it's perfectly legal to bind both a WebSocket and a traditional `get`/`post`/… 
handler on the same path:

    get("/hello", (req, resp) => resp.writeString("Hello there!"));
    websocket("/hello", (channel, text) => channel.sendText("Hello, ``text``!"));

