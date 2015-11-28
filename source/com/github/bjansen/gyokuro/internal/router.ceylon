import ceylon.collection {
	HashMap,
	ArrayList
}
import ceylon.language.meta.declaration {
	FunctionDeclaration
}
import ceylon.language.meta.model {
	Function
}
import ceylon.net.http {
	Method,
	AbstractMethod
}
import ceylon.net.http.server {
	Request,
	Response
}

shared alias Handler => [Object?, FunctionDeclaration]|Callable<Anything,[Request, Response]>;

shared object router {
	
	value root = Node("");
	
	shared void registerRoute<Param>(String route, {Method+} methods,
		Function<Anything,Param>|Callable<Anything,[Request, Response]> handler)
			given Param satisfies Anything[] {
		
		value parts = route.split('/'.equals);
		value node = findOrCreateNode(root, parts);
		
		for (method in methods) {
			if (node.handles(method)) {
				throw Exception("Route '``route``' already defined for method '``method``'.");
			}
			if (is Function<> handler) {
				node.addHandler(method, [null, handler.declaration]);
			} else {
				node.addHandler(method, handler);
			}
		}
	}
	
	shared void registerControllerRoute(String route,
		[Object, FunctionDeclaration] controllerHandler,
		{AbstractMethod+} methods) {
		
		value node = findOrCreateNode(root, route.split('/'.equals));

		for (method in methods) {
			if (node.handles(method)) {
				value handler = node.getHandler(method);
				value desc = switch (handler)
				case (is [Object?, FunctionDeclaration]) handler[1].string
				else (handler?.string else "<unknown>");
				
				throw Exception("Route '``route``' already defined for method '``method``'
				                 by handler '``desc``'.");
			}
			node.addHandler(method, controllerHandler);
		}
	}
	
	shared Boolean canHandlePath(String path) {
		return findNodeByPath(path) exists;
	}
	
	shared Handler? routeRequest(Request request) {
		if (exists node = findNodeByPath(request.path)) {
			return node.getHandler(request.method);
		}
		
		return null;
	}
	
	Node? findNodeByPath(String path) {
		value parts = path.split('/'.equals);
		variable value node = root;
		value foundNode = parts.every((part) {
			if (exists result = node.findChild(part)) {
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

class Node(shared String subPath) {
	value kids = ArrayList<Node>();
	variable Map<Method, Handler> handlers = emptyMap;
	
	shared void addChild(Node node) {
		kids.add(node);
	}
	
	shared Node? findChild(String path) {
		return kids.find((el) => el.subPath == path);
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
			handlers = HashMap<Method, Handler>();
		}
		
		assert(is HashMap<Method, Handler> h = handlers);
		h.put(method, handler);
	}

	shared void clear() {
		if (is HashMap<Method, Handler> h = handlers) {
			h.clear();
		}
		
		kids.clear();
	}
}
