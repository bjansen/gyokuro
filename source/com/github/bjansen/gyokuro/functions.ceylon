import ceylon.net.http.server {
	Request,
	Response
}
import com.github.bjansen.gyokuro.internal {
	router
}
import ceylon.net.http {
	getMethod=get,
	postMethod=post
}

shared void get(String route, void handler(Request request, Response response)) {
	router.registerRoute(route, {getMethod}, handler);
}

shared void post(String route, void handler(Request request, Response response)) {
	router.registerRoute(route, {postMethod}, handler);
}