import ceylon.collection {
    ArrayList
}
import ceylon.http.common {
    post,
    get,
    Method
}
import ceylon.http.server {
    Options,
    Request,
    newServer,
    Response,
    Server,
    startsWith,
    AsynchronousEndpoint,
    HttpEndpoint,
    Status
}
import ceylon.http.server.endpoints {
    serveStaticFile,
    RepositoryEndpoint
}
import ceylon.http.server.websocket {
    WebSocketEndpoint
}
import ceylon.io {
    SocketAddress
}
import ceylon.language.meta.declaration {
    Package
}

import net.gyokuro.core.internal {
    RequestDispatcher,
    router
}
import net.gyokuro.transform.api {
    Transformer
}
import net.gyokuro.view.api {
    TemplateRenderer
}

"A web server application that can route requests to handler functions
 or annotated controllers, and serve static assets."
shared class Application<T>(
    "The address or hostname on which the HTTP server will be bound."
    shared String address = "0.0.0.0",
    "The port on which the server will listen."
    shared Integer port = 8080,
    "Additional controllers in which [[route]]s will be scanned, that will be
     associated to the given context root.

     If a package is provided, gyokuro will look for classes and objects annotated
     with the [[controller]] annotation and instantiate them automatically.

     If a stream of [[Object]]s is provided, gyokuro will look for existing instances
     annotated with [[controller]].

     See also the [[bind]] function."
    [String, Package|{Object*}]? controllers = null,
    "A tuple [filesystem folder, context root] used to serve static assets.
     See the [[serve]] function."
    [String, String]? assets = null,
    "A context root used to serve modules."
    String? modulesPath = null,
    "Additional (chained) filters run before each request."
    Filter[] filters = [],
    "A template renderer"
    TemplateRenderer<T>? renderer = null,
    "Transformers that can serialize to responses and deserialize from request bodies."
    Transformer[] transformers = []) {

    variable Server? server = null;
    variable Boolean stopped = false;
    
    "A filter applied to each incoming request before it is dispatched to
     its matching handler. Multiple filters can be chained, and returning
     [[false]] will stop the chain. In this case, the filter returning `false`
     should modify the [[Response]] such as it can be returned to the client."
    shared alias Filter => Anything(Request, Response, Anything(Request, Response));
    
    "Starts the web application."
    shared void run(Anything(Status) statusListener = noop) {
        if (stopped) {
            return;
        }
        value endpoints = ArrayList<HttpEndpoint|WebSocketEndpoint>();
        
        if (exists modulesPath) {
            endpoints.add(RepositoryEndpoint(modulesPath));
        }

        if (exists assets) {
            value assetsEndpoint = AsynchronousEndpoint(startsWith(assets[1]),
                serveRoot(assets),
                { get, post, special });
            
            endpoints.add(assetsEndpoint);
        }

        for (path -> handler in router.webSocketHandlers) {
            WebSocketHandler wsHandler;

            if (is WebSocketHandler handler) {
                wsHandler = handler;
            } else {
                wsHandler = object extends WebSocketHandler() {
                    onText = handler;
                };
            }

            endpoints.add(WebSocketEndpoint {
                path = startsWith(path);
                onOpen = wsHandler.onOpen;
                onClose = wsHandler.onClose;
                onError = wsHandler.onError;
                onText = wsHandler.onText;
                onBinary = wsHandler.onBinary;
            });
        }
        
        endpoints.add(RequestDispatcher(controllers, filter, renderer, transformers).endpoint());
        
        value s = server = newServer(endpoints);
        s.addListener(statusListener);
        s.start(SocketAddress(address, port), Options());
        server = null;
    }

    "Stops the web application, if started, and inhibits any further attempts to start it."
    shared void stop() {
        stopped = true;
        if (exists s = server) {
            s.stop();
        }
    }
    
    object special satisfies Method {
        string => "BREW";
        hash => string.hash;
        shared actual Boolean equals(Object that) {
            if (is Method that) {
                return that.string == string;
            }
            return false;
        }
    }
    
    "Runs the first element in the filter chain. Each filter has the responsibility to
     run the next filter in the chain."
    void filter(Request req, Response resp, Anything(Request, Response) last) {
        void lastFilter(Request req, Response resp, Anything(Request, Response) next) {
            last(req, resp);
        }

        void next(Filter[] filters, Request req, Response resp) {
            if (exists filter = filters.first) {
                filter(req, resp, (newReq, newResp) {
                    next(filters.rest, newReq, newResp);
                });
            }
        }

        value ourFilters = filters.withTrailing(lastFilter);
        next(ourFilters, req, resp);
    }
    
    void serveRoot([String, String] conf)(Request req, Response resp, void complete()) {
        filter(req, resp, (req, resp) {
            if (req.method == special) {
                resp.status = 418;
                resp.writeString("418 - I'm a teapot");
            } else {
                value root = conf[1];
                value assetsPath = conf[0];
                value file = root.empty then req.path else req.path[root.size...];
                serveStaticFile(assetsPath, (req) => req.path.equals("/") then "/index.html" else file)(req, resp, complete);
            }
        });
    }
}

"Tells gyokuro to bind [[controllers|controller]] scanned in [[pkgToScan]] to the given
 [[context]] root. This function is meant to be used for [[Application.controllers]].
 
     value app = Application {
         controllers = bind(\"rest\", `package com.myapp.controllers`);
     };
 
 "
shared [String, Package|{Object*}] bind(Package|{Object*} pkgToScan, String context = "/") {
    return [context, pkgToScan];
}

"Tells gyokuro to serve static assets located in the filesystem folder [[path]] under the
 given [[context]] root. For example, all routes starting with `/public` will serve files
 located in `./assets`:
 
     value app = Application {
         assets = serve(\"assets\", \"/public\");
     };
 "
shared [String, String] serve(String path, String context = "") {
    return [path, context];
}
