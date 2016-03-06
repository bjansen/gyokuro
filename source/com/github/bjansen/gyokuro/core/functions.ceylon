import ceylon.buffer.charset {
    Charset,
    utf8
}
import ceylon.language.meta.model {
    Function
}
import ceylon.net.http {
    getMethod=get,
    postMethod=post,
    optionsMethod=options,
    deleteMethod=delete,
    connectMethod=connect,
    traceMethod=trace,
    putMethod=put,
    headMethod=head,
    sdkContentType=contentType
}
import ceylon.net.http.server {
    Request,
    Response
}

import com.github.bjansen.gyokuro.core.internal {
    router,
    HaltException,
    RedirectException
}
import com.github.bjansen.gyokuro.view.api {
    TemplateRenderer
}

"A function capable of handling a request."
shared alias Handler<Params> => Function<Anything,Params>|Callable<Anything,[Request, Response]>;

"Declares a new GET route for the given [[path]] and [[handler]]."
shared void get<Params>(String path, Handler<Params> handler)
        given Params satisfies Anything[]
        => router.registerRoute(path, { getMethod }, handler);

"Declares a new POST route for the given [[path]] and [[handler]]."
shared void post<Params>(String path, Handler<Params> handler)
        given Params satisfies Anything[]
        => router.registerRoute(path, { postMethod }, handler);

"Declares a new OPTIONS route for the given [[path]] and [[handler]]."
shared void options<Params>(String path, Handler<Params> handler)
        given Params satisfies Anything[]
        => router.registerRoute(path, { optionsMethod }, handler);

"Declares a new DELET route for the given [[path]] and [[handler]]."
shared void delete<Params>(String path, Handler<Params> handler)
        given Params satisfies Anything[]
        => router.registerRoute(path, { deleteMethod }, handler);

"Declares a new CONNECT route for the given [[path]] and [[handler]]."
shared void connect<Params>(String path, Handler<Params> handler)
        given Params satisfies Anything[]
        => router.registerRoute(path, { connectMethod }, handler);

"Declares a new TRACE route for the given [[path]] and [[handler]]."
shared void trace<Params>(String path, Handler<Params> handler)
        given Params satisfies Anything[]
        => router.registerRoute(path, { traceMethod }, handler);

"Declares a new PUT route for the given [[path]] and [[handler]]."
shared void put<Params>(String path, Handler<Params> handler)
        given Params satisfies Anything[]
        => router.registerRoute(path, { putMethod }, handler);

"Declares a new HEAD route for the given [[path]] and [[handler]]."
shared void head<Params>(String path, Handler<Params> handler)
        given Params satisfies Anything[]
        => router.registerRoute(path, { headMethod }, handler);

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
shared alias AnyTemplate<T> => Anything(TemplateRenderer<T>, Request, Response);
shared alias Template => AnyTemplate<String>;

"Renders a template that will be returned as the response body."
shared void render<T>(
    "The template name"
    T template,
    "A map of things to pass to the template."
    Map<String,Anything> context = emptyMap,
    "The content type to be used in the response."
    String contentType = "text/html",
    "The charset to be used in the response."
    Charset charset = utf8)
        (TemplateRenderer<T> renderer, Request request, Response response) {
    
    value result = renderer.render(template, context, request, response);
    
    response.addHeader(sdkContentType(contentType, charset));
    response.writeString(result);
}

"Clears every registered route."
shared void clearRoutes() {
    router.clear();
}
