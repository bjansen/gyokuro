import ceylon.http.server {
    Request,
	UploadedFile,
	Session
}
import ceylon.io {
	SocketAddress
}
import ceylon.http.common {
	Method
}

"Allows adding things to a request, like values for `:named` parts of the URL."
suppressWarnings("deprecation")
shared class RequestWrapper(Request wrappedRequest,
	Map<String,String?> newQueryParameters = emptyMap,
	String?()? contentTypeProvider = null,
	SocketAddress? newDestinationAddress = null,
	Map<String,UploadedFile?> newFiles = emptyMap,
	Map<String,String?> newHeaders = emptyMap,
	Method? newMethod = null,
	String? newPath = null,
	String? newQueryString = null,
	String()? readCallback = null,
	String? newRelativePath = null,
	String? newScheme = null,
	Session? newSession = null,
	SocketAddress? newSourceAddress = null,
	String? newUri = null,
	Map<String,String?> newFormParameters = emptyMap,
	Byte[]()? readBinaryCallback = null,
	String?()? matchedTemplateProvider = null,
	Map<String,String?> newPathParameters = emptyMap)
        satisfies Request {
    
    T? from<T>(Map<String,T?> map, T?(String) methodRef, String name) => if (map.defines(name)) then map.get(name) else methodRef(name);
    
    T[] sequence<T>(Map<String,T?> map, T[](String) methodRef, String name) {
        if (map.defines(name)) {
            return if (is T val = map.get(name)) then [val] else [];
        }
        return  methodRef(name);
    }
                 
    queryParameter(String name) => from(newQueryParameters, wrappedRequest.queryParameter, name);

    queryParameters(String name) =>  sequence(newQueryParameters, wrappedRequest.queryParameters, name);

    contentType => if (exists contentTypeProvider) then contentTypeProvider() else wrappedRequest.contentType;
    
    destinationAddress => newDestinationAddress else wrappedRequest.destinationAddress;

    file(String name) => from(newFiles, wrappedRequest.file, name);
    
    files(String name) => sequence(newFiles, wrappedRequest.files, name);

    header(String name) => from(newHeaders, wrappedRequest.header, name);
    
    headers(String name) =>  sequence(newHeaders, wrappedRequest.headers, name);
    
    method => newMethod else wrappedRequest.method;
    
    path => newPath else wrappedRequest.path;
    
    queryString => newQueryString else wrappedRequest.queryString;
    
    read() => if (exists readCallback) then readCallback() else wrappedRequest.read();
    
    relativePath => newRelativePath else wrappedRequest.relativePath;
    
    scheme => newScheme else wrappedRequest.scheme;
    
    session => newSession else wrappedRequest.session;
    
    sourceAddress => newSourceAddress else wrappedRequest.sourceAddress;
    
    uri => newUri else wrappedRequest.uri;

    formParameter(String name) => from(newFormParameters, wrappedRequest.formParameter, name);
    
    formParameters(String name) =>  sequence(newFormParameters, wrappedRequest.formParameters, name);

    parameter(String name, Boolean forceFormParsing) => wrappedRequest.parameter(name, forceFormParsing);	// deprecated so no rewriting

    parameters(String name, Boolean forceFormParsing) => wrappedRequest.parameters(name, forceFormParsing);	// deprecated so no rewriting

    readBinary() => if (exists readBinaryCallback) then readBinaryCallback() else wrappedRequest.readBinary();
    
    matchedTemplate => if (exists matchedTemplateProvider) then matchedTemplateProvider() else wrappedRequest.matchedTemplate;

    pathParameter(String name) => from(newPathParameters, wrappedRequest.pathParameter, name);

}
