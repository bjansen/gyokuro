import ceylon.io {
	SocketAddress
}
import ceylon.language.meta.declaration {
	Package
}
import ceylon.net.http {
	post,
	get,
	Method
}
import ceylon.net.http.server {
	Options,
	Request,
	newServer,
	Response,
	Server,
	startsWith,
	AsynchronousEndpoint,
	HttpEndpoint
}
import ceylon.net.http.server.endpoints {
	serveStaticFile
}

import com.github.bjansen.gyokuro.internal {
	RequestDispatcher
}
import ceylon.collection {
	ArrayList
}

"A web server application that can serve static assets and dynamic requests."
shared class Application(
	"The address or hostname on which the HTTP server will be bound."
	String address = "0.0.0.0",
	"The port on which the server will listen."
	Integer port = 8080,
	"A tuple [context root, package] used to scan [[controllers|controller]]
	 that will be associated to the given context root. See the [[bind]] function."
	[String, Package]? controllers = null,
	"A tuple [filesystem folder, context root] used to serve static assets.
 	 See the [[serve]] function."
	[String, String]? assets = null,
	"Additional (chained) filters run before each request."
	Filter[] filters = [],
    "A template renderer"
    TemplateRenderer? renderer = null) {
    
    shared alias Filter => Boolean(Request, Response);
    
    "Starts the web application."
    shared void run() {
        value endpoints = ArrayList<HttpEndpoint>();

		endpoints.add(RequestDispatcher(controllers, filter, renderer).endpoint());
		
        if (exists assets) {
            value assetsEndpoint = AsynchronousEndpoint(startsWith(assets[1]),
                serveRoot(assets), 
                { get, post, special });
            
            endpoints.add(assetsEndpoint);
        }
        
        Server server = newServer(endpoints);
        server.start(SocketAddress(address, port), Options());
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
    
    "Runs each filter successively until one them returns `false` or every filter was run.
     If each filter returned `true`, this means we can continue serving the request."
    Boolean filter(Request req, Response resp) {
        for (f in filters) {
            if (!f(req, resp)) {
                return false;
            }
        }
        return true;
    }
    
    void serveRoot([String, String] conf)(Request req, Response resp, void complete()) {
        if (!filter(req, resp)) {
            return;
        }
        
        if (req.method == special) {
            resp.responseStatus = 418;
            resp.writeString("418 - I'm a teapot");
        } else {
            value root = conf[1];
            value assetsPath = conf[0];
            value file = root.empty then req.path else req.path[root.size...];
            serveStaticFile(assetsPath, (req) => req.path.equals("/") then "/index.html" else file)(req, resp, complete);
        }
    }
}

"Tells gyokuro to bind [[controllers|controller]] scanned in [[pkgToScan]] to the given
 [[context]] root. This function is meant to be used for [[Application.controllers]].
 
     value app = Application {
     	controllers = bind(\"rest\", `package com.myapp.controllers`);
     };
 
 "
shared [String, Package] bind(Package pkgToScan, String context = "/") {
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