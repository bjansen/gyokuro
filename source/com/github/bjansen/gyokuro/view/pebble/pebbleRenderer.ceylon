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
import com.mitchellbosecke.pebble.loader {
    FileLoader
}
import com.mitchellbosecke.pebble {
    PebbleEngine
}
import java.io {
    StringWriter
}
import ceylon.interop.java {
    JavaList,
    JavaIterable,
    javaString
}
import com.github.bjansen.gyokuro.view.api {
	TemplateRenderer
}

shared class PebbleRenderer(prefix, suffix, contextEnhancer = noop)
        satisfies TemplateRenderer {
    
    String prefix;
    
    String suffix;
    
    void contextEnhancer(Request req, Response resp, JMap<JString, Object> context);
    
    value loader = FileLoader();
    shared PebbleEngine engine = PebbleEngine(loader);
    
    loader.prefix = prefix;
    loader.suffix = suffix; 

    shared actual String render(String templateName, Map<String,Anything> context,
        Request req, Response resp) {
        
        value tpl = engine.getTemplate(templateName);
        value writer = StringWriter();
        value jMap = wrapMap(context, req, resp);
        
        tpl.evaluate(writer, jMap);
        
        return writer.string;
    }
    
    JMap<JString,Object> wrapMap(Map<String,Anything> context,
        Request request, Response response) {
        
        value result = HashMap<JString, Object>();
        
        contextEnhancer(request, response, result);
        
        for (key -> val in context) {
            value javaVal = switch(val)
            case (is List<Nothing>) JavaList(val)
            else if (is Iterable<> val) then JavaIterable(val)
            else val;
            
            result.put(javaString(key), javaVal else null);
        }
        
        return result;
    }

}
