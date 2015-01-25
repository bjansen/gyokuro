import ceylon.net.http.server {
	Response
}
import com.github.bjansen.gyokuro {
	controller,
	route
}

controller class SimpleRestController() {
	
	route("coin")
	shared void myfunc(Response resp) {
		resp.writeString("Hello world!");
	}
}