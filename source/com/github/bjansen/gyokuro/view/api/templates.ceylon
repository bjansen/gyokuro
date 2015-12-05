import ceylon.net.http.server {
	Request,
	Response
}

"A wrapper for a template engine capable of rendering
 a template to a [[String]]."
shared interface TemplateRenderer {
    shared formal String render(
        "The template to be rendered."
    	String templateName,
        "A map of named values that can be used in the template."
        Map<String, Anything> context,
        "The HTTP request."
        Request req,
        "The HTTP response."
        Response resp);
}