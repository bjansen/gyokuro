import ceylon.collection {
    HashMap
}
import ceylon.io.charset {
    utf8
}
import ceylon.language.meta {
    classDeclaration,
    type
}
import ceylon.language.meta.declaration {
    FunctionDeclaration,
    Package,
    ValueDeclaration,
    FunctionOrValueDeclaration,
    OpenUnion,
    OpenType,
    OpenClassType
}
import ceylon.language.meta.model {
    InterfaceModel
}
import ceylon.logging {
    logger
}
import ceylon.net.http {
    post,
    get,
    contentType,
    Header,
    options,
    head,
    put,
    delete,
    trace,
    connect
}
import ceylon.net.http.server {
    Response,
    Request,
    Endpoint,
    Matcher,
    UploadedFile
}

import com.github.bjansen.gyokuro.core {
    SessionAnnotation,
    Flash,
    mimeParse,
    AnyTemplate
}
import com.github.bjansen.gyokuro.transform.api {
    Transformer
}
import com.github.bjansen.gyokuro.view.api {
    TemplateRenderer
}

shared class RequestDispatcher<T>([String, Package]? packageToScan, Boolean(Request, Response) filter,
    TemplateRenderer<T>? renderer = null, Transformer[] transformers = []) {
    
    value log = logger(`module com.github.bjansen.gyokuro.core`);
    
    Converter<out Object>[] converters = [primitiveTypesConverter, listsConverter];
    
    if (exists [contextRoot, declaration] = packageToScan) {
        annotationScanner.scanControllersInPackage(contextRoot, declaration);
    }
    
    object routerMatcher extends Matcher() {
        shared actual Boolean matches(String path)
                => router.canHandlePath(path);
    }
    
    shared Endpoint endpoint() {
        return Endpoint(routerMatcher, dispatch,
            { options, get, head, post, put, delete, trace, connect });
    }
    
    "Dispatch the incoming request to the matching method."
    void dispatch(Request req, Response resp) {
        if (!filter(req, resp)) {
            return;
        }
        
        value namedParams = HashMap<String,String>();
        
        if (is Handler? handler = router.routeRequest(req, namedParams)) {
            if (!exists handler) {
                // We know this path, but not for this method
                respond(405, "Method Not Allowed", resp);
                return;
            }
            value enhancedReq = if (namedParams.empty)
            then req else RequestWrapper(req, namedParams);
            
            if (is [Object?, FunctionDeclaration] handler) {
                dispatchToController(enhancedReq, resp, handler);
            } else {
                writeResult(handler(enhancedReq, resp), req, resp);
            }
        } else {
            respond(404, "Not Found", resp);
        }
    }
    
    void dispatchToController(Request req, Response resp, [Object?, FunctionDeclaration] handler) {
        value func = handler[1];
        value args = HashMap<String,Anything>();
        
        try {
            for (param in func.parameterDeclarations) {
                value arg = bindParameter(param, req, resp);
                
                if (exists arg) {
                    args.put(param.name, arg);
                } else if (param.defaulted) {
                    // use default value
                } else if (isOptional(param)) {
                    args.put(param.name, null);
                } else {
                    throw BindingException("Cannot bind parameter ``param.name``");
                }
            }
        } catch (BindingException e) {
            log.error("", e);
            respond(400, "Bad Request", resp);
            return;
        }
        
        try {
            value method = if (exists o = handler[0])
            then func.memberApply<>(type(o)).bind(o)
            else func.apply<Anything,Nothing>();
            value result = method.namedApply(args);
            writeResult(result, req, resp);
        } catch (HaltException e) {
            respond(e.errorCode, e.message, resp);
        } catch (RedirectException e) {
            resp.addHeader(Header("Location", e.url));
            respond(e.redirectCode, "Moved", resp);
        } catch (AssertionError|Exception e) {
            log.error("Invocation of ``func.qualifiedName`` threw an error:\n", e);
            respond(500, "Internal Server Error", resp);
        }
    }
    
    Boolean isOptional(FunctionOrValueDeclaration param) {
        if (is OpenUnion paramType = param.openType, paramType.caseTypes.size == 2) {
            if (exists nullType = paramType.caseTypes.find((elem) => elem == `class Null`.openType)) {
                return true;
            }
        }
        return false;
    }
    
    OpenType getNonOptionalType(FunctionOrValueDeclaration param) {
        assert (is OpenUnion paramType = param.openType);
        
        value nonOptionalType = paramType.caseTypes.find((elem) => elem != `class Null`.openType);
        
        assert (exists nonOptionalType);
        
        return nonOptionalType;
    }
    
    Anything? bindParameter(FunctionOrValueDeclaration param, Request req, Response resp) {
        if (is ValueDeclaration param) {
            if (param.openType == `interface Response`.openType) {
                return resp;
            } else if (param.openType == `interface Request`.openType) {
                return req;
            } else if (param.openType == `interface Flash`.openType) {
                return DefaultFlash(req.session);
            } else if (param.annotated<SessionAnnotation>()) {
                return bindSessionValue(param, req);
            } else {
                return bindRequestParameter(param, req);
            }
        }
        
        return null;
    }
    
    Anything? bindSessionValue(ValueDeclaration param, Request req) {
        if (exists val = req.session.get(param.name)) {
            value valType = classDeclaration(val).qualifiedName;
            
            if (valType == param.openType.string) {
                return val;
            } else if (is String val) {
                return convertParameter(param, val);
            } else {
                throw BindingException("Cannot bind parameter ``param.name`` from session: \
                                                    type ``valType`` cannot be assigned nor converted \
                                                    to ``param.openType``");
            }
        }
        return null;
    }
    
    Anything? bindRequestParameter(ValueDeclaration param, Request req) {
        
        if (exists val = getValueFromRequest(req, param)) {
            return convertParameter(param, val);
        }
        // missing values can still be mapped to List or Sequential
        if (listsConverter.supports(param.openType)) {
            return listsConverter.convert(param.openType, []);
        }
        
        // Try to deserialize using a Transformer
        if (exists contentType = req.contentType,
            is OpenClassType ot = param.openType,
            exists tr = transformers.find((t) => t.contentTypes.contains(contentType)),
            exists meth = `Transformer`.getMethod<>("deserialize", ot.declaration.apply<>())) {
        
            try {
                return meth.bind(tr).apply(req.read());
            } catch (Exception e) {
                throw BindingException("Could not deserialize request body to \
                                        ``param.qualifiedName``", e);
            }
        }
        
        return null;
    }
    
    Anything getValueFromRequest(Request req, ValueDeclaration decl) {
        value targetType = if (isOptional(decl))
        then getNonOptionalType(decl)
        else decl.openType;
        
        if (targetType == `UploadedFile`.declaration.openType) {
            return req.file(decl.name);
        } else if (listsConverter.supports(targetType)) {
            if (exists typeArg = listsConverter.getTypeArgument(targetType),
                typeArg == `UploadedFile`.declaration.openType) {
                
                return req.files(decl.name);
            }
            return req.parameters(decl.name);
        }
        
        return req.parameter(decl.name);
    }
    
    Anything convertParameter(ValueDeclaration param, Object val) {
        value targetType = if (isOptional(param)) then getNonOptionalType(param) else param.openType;
        
        for (converter in converters) {
            if (converter.supports(targetType)) {
                if (is String[] val, is MultiConverter converter) {
                    return converter.convert(targetType, val);
                } else if (is String val, is Converter<String> converter) {
                    return converter.convert(targetType, val);
                }
            }
        }
        
        throw BindingException("Cannot bind parameter ``param.name``: \
                                      no converter found for type ``param.openType``");
    }
    
    void writeResult(Anything result, Request req, Response resp) {
        if (is AnyTemplate<T> result) {
            if (is TemplateRenderer<T> renderer) {
                result(renderer, req, resp);
            } else {
                respond(500, "No template renderer is configured.", resp);
            }
        } else if (is String result) {
            resp.addHeader(contentType("text/plain", utf8));
            resp.writeString(result);
        } else if (exists result, satisfiesHtmlNode(result)) {
            resp.addHeader(contentType("text/html", utf8));
            resp.writeString(result.string);
        } else if (is Object result, exists tr = findTransformerFor(req)) {
            // TODO if the transformer accepts text/*, we can't set the content type to text/*
            log.trace("Matched content type ``req.header("Accept") else "*"`` to \
                       response transformer ``className(tr[0])``");
            resp.addHeader(contentType(tr[1], utf8));
            resp.writeString(tr[0].serialize(result));
        } else if (is Object result) {
            respond(500, "Don't know how to write ``className(result)`` to response", resp);
        } else {
            resp.writeString("");
        }
    }

    [Transformer, String]? findTransformerFor(Request req) {
        value accept = req.header("Accept") else "*";
        
        for (tr in transformers) {
            if (exists match = mimeParse.bestMatch(tr.contentTypes, accept)) {
                return [tr, match];
            }
        }
        
        return null;
    }
    
    void respond(Integer code, String? message, Response resp) {
        resp.responseStatus = code;
        resp.writeString("<html><head><title>Error</title></head><body>"
                    + code.string + " - " + (message else "") + "</body></html>");
    }
    
    // Checks for HTML nodes without having a hardcoded dependency on `ceylon.html`
    Boolean satisfiesHtmlNode(Object result)
            => modelSatisfiesHtmlNode(type(result).satisfiedTypes);
    
    Boolean modelSatisfiesHtmlNode(InterfaceModel<Anything>[] satisfied) {
        value node = "ceylon.html::Node";
        
        return satisfied.find((st) => 
            st.declaration.qualifiedName == node || modelSatisfiesHtmlNode(st.satisfiedTypes)
        ) exists;
    }
}

class BindingException(String? description = null, Throwable? cause = null)
        extends Exception(description, cause) {
}

shared class HaltException(shared Integer errorCode, String? message = null)
        extends Exception(message) {
}

shared class RedirectException(shared String url, shared Integer redirectCode)
        extends Exception() {
}
