import ceylon.http.server {
    Request
}

import java.lang {
    JString=String,
    ObjectArray
}
import java.lang.reflect {
    InvocationHandler,
    Method
}

"Allows adding things to a request, like values for `:named` parts of the URL."
class RequestWrapper(Request req, Map<String,String> namedParams)
        satisfies InvocationHandler {

    shared actual Object? invoke(Object proxy, Method method, ObjectArray<Object>? args) {
        if (method.name == "queryParameter", exists args, args.size == 1, is JString arg = args[0]) {
            return queryParameter(req, arg.string);
        }
        if (method.name == "queryParameters", exists args, args.size == 1, is JString arg = args[0]) {
            return queryParameters(req, arg.string);
        }

        return if (exists args)
        then method.invoke(req,  *args)
        else method.invoke(req);
    }

    shared String? queryParameter(Request req, String name) {
        if (namedParams.defines(name)) {
            return namedParams.get(name);
        }
        return req.queryParameter(name);
    }

    shared String[] queryParameters(Request req, String name) {
        if (namedParams.defines(name)) {
            assert (exists val = namedParams.get(name));
            return [val];
        }
        return req.queryParameters(name);
    }
}
