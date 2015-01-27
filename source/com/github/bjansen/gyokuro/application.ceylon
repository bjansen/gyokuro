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
import ceylon.net.http.server.endpoints {
	serveStaticFile
}

shared class Application(Integer port, String rootContext, Package pkg) {
	
	shared variable String assetsPath = "";

	shared void run() {
		value assetsEndpoint = Endpoint(startsWith(""), serveRoot, {get, post, special});
		value dispatcher = RequestDispatcher(rootContext, pkg);
		
		Server server = newServer({dispatcher.endpoint(), assetsEndpoint});
		server.start(SocketAddress("localhost", port), Options());
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

	void serveRoot(Request req, Response resp) {
		if (req.method == special) {
			resp.responseStatus = 418;
			resp.writeString("418 - I'm a teapot");
		} else {
			serveStaticFile(assetsPath, (req) => req.path.equals("/") then "/index.html" else req.path)(req, resp, () => {});
		}
	}
}