import ceylon.net.http.server {
	Response,
	Request
}
import com.github.bjansen.gyokuro {
	controller,
	route
}

route("duck")
controller class SimpleRestController() {
	
	route("talk")
	shared void makeDuckTalk(Response resp, Request req) {
		resp.writeString("Quack world!");
	}
}