import ceylon.net.http.server {
	Request,
	Session,
	UploadedFile
}
import ceylon.net.http {
	Method
}
import ceylon.io {
	SocketAddress
}

"Allows adding things to a request, like values for `:named` parts of the URL."
class RequestWrapper(Request req, Map<String, String> namedParams)
		satisfies Request {

	// IMPORTANT STUFF
	
	shared actual String? parameter(String name, Boolean forceFormParsing) { 
		if (namedParams.defines(name)) {
			return namedParams.get(name);
		}
		return req.parameter(name, forceFormParsing);
	}
	
	shared actual String[] parameters(String name, Boolean forceFormParsing) {
		if (namedParams.defines(name)) {
			assert(exists val = namedParams.get(name));
			return [val];
		}
		return req.parameters(name, forceFormParsing);
	}
	
	// DELEGATION
	
	shared actual String? contentType => req.contentType;
	
	shared actual SocketAddress destinationAddress => req.destinationAddress;
	
	shared actual UploadedFile? file(String name) => req.file(name);
	
	shared actual UploadedFile[] files(String name) => req.files(name);
	
	shared actual String? header(String name) => req.header(name);
	
	shared actual String[] headers(String name) => req.headers(name);
	
	shared actual Method method => req.method;
	
	shared actual String path => req.path;
	
	shared actual String queryString => req.queryString;
	
	shared actual String read() => req.read();
	
	shared actual String relativePath => req.relativePath;
	
	shared actual String scheme => req.scheme;
	
	shared actual Session session => req.session;
	
	shared actual SocketAddress sourceAddress => req.sourceAddress;
	
	shared actual String uri => req.uri;
}
