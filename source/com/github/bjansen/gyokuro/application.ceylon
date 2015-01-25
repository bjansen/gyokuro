import ceylon.io {
	SocketAddress
}
import ceylon.language.meta.declaration {
	Package
}
import ceylon.net.http {
	post,
	get
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
		value assetsEndpoint = Endpoint(startsWith(""), serveRoot, {get, post});
		value dispatcher = RequestDispatcher(rootContext, pkg);
		
		Server server = newServer({dispatcher.endpoint(), assetsEndpoint});
		server.start(SocketAddress("localhost", port), Options());
	}
	
	void serveRoot(Request req, Response resp) {
		serveStaticFile(assetsPath, (req) => req.path.equals("/") then "/index.html" else req.path)(req, resp, () => {});
	}
}