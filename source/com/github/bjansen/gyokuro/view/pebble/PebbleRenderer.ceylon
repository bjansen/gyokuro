import ceylon.net.http.server {
    Request,
    Response
}

import com.github.bjansen.gyokuro.view.api {
    JavaTemplateRenderer
}
import com.mitchellbosecke.pebble {
    PebbleEngine
}
import com.mitchellbosecke.pebble.loader {
    FileLoader
}

import java.io {
    StringWriter
}
import java.lang {
    JString=String
}
import java.util {
    JMap=Map
}

"A [[com.github.bjansen.gyokuro.view.api::TemplateRenderer]] based on the 
 [Pebble](http://www.mitchellbosecke.com/pebble) templating engine."
shared class PebbleRenderer(prefix = null, suffix = null, contextEnhancer = noop)
        extends JavaTemplateRenderer(contextEnhancer) {
    
    "The optional prefix passed to the [[FileLoader]], for example `views/`."
    String? prefix;
    
    "The optional suffix passed to the [[FileLoader]], for example `.pebble`."
    String? suffix;
    
    "A callback that can add custom entries to the context before passing it to Pebble."
    void contextEnhancer(Request req, Response resp, JMap<JString,Object> context);
    
    value loader = FileLoader();
    
    "The Pebble engine."
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
}
