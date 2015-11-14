import ceylon.net.http {
	getMethod=get,
	postMethod=post
}

import com.github.bjansen.gyokuro.internal {
	router
}
import ceylon.language.meta.model {
	Function
}
import ceylon.net.http.server {
	Request,
	Response
}

shared void get<Params>(String route,
	Function<Anything,Params>|Callable<Anything,[Request, Response]> handler)
		given Params satisfies Anything[] {
	
	router.registerRoute(route, { getMethod }, handler);
}

shared void post<Params>(String route,
	Function<Anything,Params>|Callable<Anything,[Request, Response]> handler)
		given Params satisfies Anything[] {
	
	router.registerRoute(route, { postMethod }, handler);
}
