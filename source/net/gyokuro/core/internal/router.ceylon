import ceylon.collection {
    HashMap,
    ArrayList
}
import ceylon.http.common {
    Method,
    AbstractMethod
}
import ceylon.http.server {
    Request,
    Response
}
import ceylon.language.meta.declaration {
    FunctionDeclaration
}
import ceylon.language.meta.model {
    Function
}

import net.gyokuro.core {
    WSHandler
}

shared alias Handler => [Object?, FunctionDeclaration]|Callable<Anything,[Request, Response]>;

shared object router {

    value wsHandlers = HashMap<String, WSHandler>();

    shared Node root = Node("");
    shared Map<String, WSHandler> webSocketHandlers
        => wsHandlers;

    shared void registerRoute<Param>(String path, {Method+} methods,
        Function<Anything,Param>|Callable<Anything,[Request, Response]> handler)
            given Param satisfies Anything[] {
        
        value parts = path.rest.split('/'.equals);
        value node = findOrCreateNode(root, parts);
        
        for (method in methods) {
            if (node.handles(method)) {
                throw Exception("Path '``path``' already defined for method '``method``'.");
            }
            if (is Function<> handler) {
                node.addHandler(method, [null, handler.declaration]);
            } else {
                node.addHandler(method, handler);
            }
        }
    }
    
    shared void registerControllerRoute(String path,
        [Object, FunctionDeclaration] controllerHandler,
        {AbstractMethod+} methods) {
        
        value node = findOrCreateNode(root, path.rest.split('/'.equals));
        
        for (method in methods) {
            if (node.handles(method)) {
                value handler = node.getHandler(method);
                value desc = switch (handler)
                    case (is [Object?, FunctionDeclaration]) handler[1].string
                    else (handler?.string else "<unknown>");
                
                throw Exception("Path '``path``' already defined for method '``method``'
                                             by handler '``desc``'.");
            }
            node.addHandler(method, controllerHandler);
        }
    }

    shared void registerWebSocketHandler(String path, WSHandler handler) {

        if (webSocketHandlers.defines(path)) {
            throw Exception("Trying to override WebSocket handler for path ``path``.");
        } else {
            wsHandlers.put(path, handler);
        }
    }

    shared Boolean canHandlePath(String path) {
        return findNodeByPath(path) exists;
    }
    
    shared Handler?|Boolean routeRequest(Request request, HashMap<String,String> namedParams) {
        if (exists node = findNodeByPath(request, namedParams)) {
            return node.getHandler(request.method);
        }
        
        return false;
    }
    
    Node? findNodeByPath(String|Request obj, HashMap<String,String>? namedParams = null) {
        value path = if (is String obj) then obj else obj.path;
        value parts = path.rest.split('/'.equals, true, false);
        variable value node = root;
        value foundNode = parts.every((part) {
                if (exists result = node.findChild(part)) {
                    if (result.isNamedParameter,
                        is Request req = obj,
                        exists namedParams) {
                        if (part == "") {
                            // TODO halt(404) because the route is not valid,
                            // or throw later if the handler's parameter is not optional?
                        } else {
                            namedParams.put(result.subPath.rest, part);
                        }
                    }
                    node = result;
                    return true;
                }
                return false;
            });
        
        return foundNode then node else null;
    }
    
    Node findOrCreateNode(Node root, {String*} path) {
        return path.fold(root)(
            (node, nosubPath) => node.findOrCreateChild(nosubPath)
        );
    }
    
    shared void clear() {
        root.clear();
    }
}

shared class Node(shared String subPath) {
    
    shared Boolean isNamedParameter =
            if (exists first = subPath.first, first == ':')
    then true else false;
    
    if (isNamedParameter) {
        value isValidIdentifier = if (subPath.size > 1,
            exists firstChar = subPath[1],
            firstChar.lowercase || firstChar=='_',
            subPath.rest.every((e) => e.letter || e=='_' || e.digit))
        then true else false;
        
        if (!isValidIdentifier) {
            throw BindingException("Invalid named parameter '``subPath``', expected
                                             semicolon followed by a valid Ceylon LIdentifier");
        }
    }
    
    value kids = ArrayList<Node>();
    variable Map<Method,Handler> handlers = emptyMap;

    shared void addChild(Node node) {
        kids.add(node);
    }
    
    shared Node? findChild(String path) {
        return kids.find((el) => el.isNamedParameter || el.subPath==path);
    }
    
    shared Node findOrCreateChild(String path) {
        if (exists child = findChild(path)) {
            return child;
        }
        
        value child = Node(path);
        addChild(child);
        return child;
    }
    
    shared Boolean handles(Method method) {
        return handlers.defines(method);
    }
    
    shared Handler? getHandler(Method method) {
        return handlers.get(method);
    }
    
    shared void addHandler(Method method, Handler handler) {
        if (handlers == emptyMap) {
            handlers = HashMap<Method,Handler>();
        }
        
        assert (is HashMap<Method,Handler> h = handlers);
        h.put(method, handler);
    }
    
    shared void clear() {
        if (is HashMap<Method,Handler> h = handlers) {
            h.clear();
        }
        
        kids.clear();
    }
}
