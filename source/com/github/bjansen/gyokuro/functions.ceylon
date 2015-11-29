import ceylon.net.http {
	getMethod=get,
	postMethod=post,
    sdkContentType=contentType
}

import com.github.bjansen.gyokuro.internal {
	router,
	HaltException,
	RedirectException
}
import ceylon.language.meta.model {
	Function
}
import ceylon.net.http.server {
	Request,
	Response
}
import ceylon.io.charset {
    Charset,
    utf8
}

shared void get<Params>(String path,
	Function<Anything,Params>|Callable<Anything,[Request, Response]> handler)
		given Params satisfies Anything[] {
	
	router.registerRoute(path, { getMethod }, handler);
}

shared void post<Params>(String path,
	Function<Anything,Params>|Callable<Anything,[Request, Response]> handler)
		given Params satisfies Anything[] {
	
	router.registerRoute(path, { postMethod }, handler);
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

"Interrupts the current handler immediately, and asks the client
 browser to redirect to the specified [[url]].
 
 	shared void login(String username, String password) {
 		if (exists user = ...) {
 			session.put(\"user\", user);
 			redirect(\"/\");
 		}
 		...
 	}
 "
shared Nothing redirect(String url, Integer redirectCode = 303) {
	throw RedirectException(url, redirectCode);
}

"A template that can be called by a [[TemplateRenderer]]."
shared alias Template => Callable<Anything, [TemplateRenderer, Request, Response]>;

"Renders a template that will be returned as the response body."
shared void render(
		"The template name"
		String templateName,
		"A map of things to pass to the template."
		Map<String, Anything> context = emptyMap,
		"The content type to be used in the response."
		String contentType = "text/html",
		"The charset to be used in the response."
		Charset charset = utf8)
		(TemplateRenderer renderer, Request request, Response response) {

	value result = renderer.render(templateName, context, request, response);
	
	response.addHeader(sdkContentType(contentType, charset));
	response.writeString(result);
}

shared void clearRoutes() {
	router.clear();
}