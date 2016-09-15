import ceylon.http.server {
    Request
}

"Allows adding things to a request, like values for `:named` parts of the URL."
class RequestWrapper(Request req, Map<String,String> namedParams)
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
            assert (exists val = namedParams.get(name));
            return [val];
        }
        return req.parameters(name, forceFormParsing);
    }
    
    // DELEGATION

    contentType => req.contentType;
    
    destinationAddress => req.destinationAddress;
    
    file(String name) => req.file(name);
    
    files(String name) => req.files(name);
    
    header(String name) => req.header(name);
    
    headers(String name) => req.headers(name);
    
    method => req.method;
    
    path => req.path;
    
    queryString => req.queryString;
    
    read() => req.read();
    
    relativePath => req.relativePath;
    
    scheme => req.scheme;
    
    session => req.session;
    
    sourceAddress => req.sourceAddress;
    
    uri => req.uri;
    
    formParameter(String name) => req.formParameter(name);
    
    formParameters(String name) => req.formParameters(name);
    
    queryParameter(String name) => req.queryParameter(name);
    
    queryParameters(String name) => req.queryParameters(name);
    
    readBinary() => req.readBinary();
    
    matchedTemplate => req.matchedTemplate;
    
    pathParameter(String name) => req.pathParameter(name);
}
