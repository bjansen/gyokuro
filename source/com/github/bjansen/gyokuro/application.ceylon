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

shared class Application(Integer port, String rootContext, Package pkg) {
	
	shared alias Filter => Boolean(Request, Response);
	shared variable String assetsPath = "";
	shared variable Filter[] filters = [];

	shared void run() {
		value assetsEndpoint = Endpoint(startsWith(""), serveRoot, {get, post, special});
		value dispatcher = RequestDispatcher(rootContext, pkg, filter);
		
		Server server = newServer({dispatcher.endpoint(), assetsEndpoint});
		server.start(SocketAddress("0.0.0.0", port), Options());
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