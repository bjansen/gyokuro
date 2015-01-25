import com.github.bjansen.gyokuro {
	Application
}

"Run an HTTP server listening on port 8080. REST controllers located in package `gyokuro.demo.rest`
 will be bound to the root context `/rest`."
shared void run() {
	 value app = Application(8080, "/rest", `package gyokuro.demo.rest`);
	 
	 app.assetsPath = "assets";
	 
	 app.run(); 
}