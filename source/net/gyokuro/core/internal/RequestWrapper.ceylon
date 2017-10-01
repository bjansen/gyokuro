import ceylon.http.server {
    Request
}

"Allows adding things to a request, like values for `:named` parts of the URL."
suppressWarnings ("deprecation")
class RequestWrapper(Request req, Map<String,String> namedParams)
        satisfies Request {

    // IMPORTANT STUFF

    shared actual String? queryParameter(String name) {
        if (namedParams.defines(name)) {
            return namedParams.get(name);
        }
        return req.queryParameter(name);
    }

    shared actual String[] queryParameters(String name) {
        if (namedParams.defines(name)) {
            assert (exists val = namedParams.get(name));
            return [val];
        }
        return req.queryParameters(name);
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

    parameter(String name, Boolean forceFormParsing) => req.parameter(name, forceFormParsing);

    parameters(String name, Boolean forceFormParsing) => req.parameters(name, forceFormParsing);

    readBinary() => req.readBinary();

    matchedTemplate => req.matchedTemplate;

    pathParameter(String name) => req.pathParameter(name);

    locale => req.locale;

    locales => req.locales;

    requestCharset => req.requestCharset;

}
