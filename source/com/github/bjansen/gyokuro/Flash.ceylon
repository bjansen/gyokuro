import ceylon.net.http.server {
	Session
}
import com.github.bjansen.gyokuro.internal {
	DefaultFlash
}

"A holder for special messages stored in the session,
 meant to be used exactly once. Flash messages are removed
 from the session as soon as they are accessed."
shared interface Flash {
	"Adds a flash object to the session."
	shared formal void add(String key, Object val);
	
	"Gets a flash object if it exists, and removes it
	 immediately from the session."
	shared formal Object? get(String key);
	
	"Gets a flash object if it exists, without removing
	 it from the session."
	shared formal Object? peek(String key);
}

"Creates a new instance of a [[Flash]]. You shouldn't have
 to use this function directly unless you are creating a custom
 [[TemplateRenderer]]. If you want to access a `Flash` instance
 from a handler, use parameters injection instead:
 
 	route(\"/login\")
 	shared void login(Flash flash) {
 		if (loginOk()) {
 			flash.add(\"info\", \"You have been logged in\");
 			redirect(\"/\");
 		}
 	}
 "
shared Flash newFlash(Session session)
	=> DefaultFlash(session);