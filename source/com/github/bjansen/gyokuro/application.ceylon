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
    Endpoint,
    Server,
    startsWith
}
import com.github.bjansen.gyokuro.internal {
	RequestDispatcher,
	myServeStaticFile
}

shared class Application(String address = "0.0.0.0", Integer port = 8080, [String, Package]? restEndpoint = null) {
    
    shared alias Filter => Boolean(Request, Response);
    shared variable String assetsPath = "";
    shared variable Filter[] filters = [];
    
    shared void run() {
        value assetsEndpoint = Endpoint(startsWith(""), serveRoot, { get, post, special });
        
        value endpoints = if (exists restEndpoint)
                          then {RequestDispatcher(restEndpoint[0], restEndpoint[1], filter).endpoint(), assetsEndpoint}
                          else {assetsEndpoint};
        
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
    
    void serveRoot(Request req, Response resp) {
        if (!filter(req, resp)) {
            return;
        }
        
        if (req.method == special) {
            resp.responseStatus = 418;
            resp.writeString("418 - I'm a teapot");
        } else {
            myServeStaticFile(assetsPath, (req) => req.path.equals("/") then "/index.html" else req.path)(req, resp, () => {});
        }
    }
}
