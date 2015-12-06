import ceylon.net.http.server {
    Request,
    Response
}
import java.lang {
    JString=String
}
import java.util {
    JMap=Map,
    HashMap
}
import ceylon.interop.java {
    JavaList,
    javaString,
    JavaIterable
}

"A wrapper for a template engine capable of rendering
 a template to a [[String]]."
shared interface TemplateRenderer {
    shared formal String render(
        "The template to be rendered."
        String templateName,
        "A map of named values that can be used in the template."
        Map<String,Anything> context,
        "The HTTP request."
        Request req,
        "The HTTP response."
        Response resp);
}

"An abstract [[TemplateRenderer]] based on a Java templating engine, that automatically
 converts Ceylon collections to Java collections."
shared abstract class JavaTemplateRenderer(contextEnhancer = noop)
        satisfies TemplateRenderer {
    
    "A callback that can add custom entries to the context before
     passing it to the templating engine."
    void contextEnhancer(Request req, Response resp, JMap<JString,Object> context);

    shared JMap<JString,Object> wrapMap(Map<String,Anything> context,
        Request request, Response response) {
        
        value result = HashMap<JString,Object>();
        
        contextEnhancer(request, response, result);
        
        for (key->val in context) {
            value javaVal = switch (val)
            case (is List<Nothing>) JavaList(val)
            else if (is Iterable<> val) then JavaIterable(val)
            else val;
            
            result.put(javaString(key), javaVal else null);
        }
        
        return result;
    }
}
