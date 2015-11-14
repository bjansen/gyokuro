import ceylon.net.http {
	getMethod=get,
	postMethod=post
}

import com.github.bjansen.gyokuro.internal {
	router,
	HaltException
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

"Interrupts the current handler immediately, resulting in an HTTP
 response with code [[errorCode]] and a body equal to [[message]].
 
 This can be used for example to indicate that something was
 not found in the database:
 
     shared void findAuthor(Integer authorId) {
         value author = authorDao.findById(authorId) 
         	else halt(404, \"Author not found\");
     }
 "
shared Nothing halt(Integer errorCode, String? message = null) {
	throw HaltException(errorCode, message);
}