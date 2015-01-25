import ceylon.net.http.server {
	Response
}
import com.github.bjansen.gyokuro {
	controller,
	route
}

route("duck")
controller class SimpleRestController() {
	
	route("talk")
	shared void makeDuckTalk(Response resp) {
		resp.writeString("Quack world!");
	}
}