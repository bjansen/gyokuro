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

"A web server application that can serve static assets and dynamic requests."
shared class Application(
	"The address or hostname on which the HTTP server will be bound."
	String address = "0.0.0.0",
	"The port on which the server will listen."
	Integer port = 8080,
	"A tuple [context root, package] used to scan [[controllers|controller]]
	 that will be associated to the given context root."
	[String, Package]? restEndpoint = null,
	"A path to look for static assets served under `/`."
	String assetsPath = "",
	"Additional (chained) filters run before each request."
	Filter[] filters = []) {
    
    shared alias Filter => Boolean(Request, Response);
    
    "Starts the web application."
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
