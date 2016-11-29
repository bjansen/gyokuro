import ceylon.http.server {
    Request,
    Response
}

import net.gyokuro.view.api {
    JavaTemplateRenderer
}
import com.mitchellbosecke.pebble {
    PebbleEngine {
        Builder
    }
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

"A [[net.gyokuro.view.api::TemplateRenderer]] based on the
 [Pebble](http://www.mitchellbosecke.com/pebble) templating engine."
shared class PebbleRenderer(prefix = null, suffix = null, contextEnhancer = noop, builder = noop)
        extends JavaTemplateRenderer(contextEnhancer) {
    
    "The optional prefix passed to the [[FileLoader]], for example `views/`."
    String? prefix;
    
    "The optional suffix passed to the [[FileLoader]], for example `.pebble`."
    String? suffix;
    
    "A callback that can add custom entries to the context before passing it to Pebble.
     Custom entries can be overriden by handlers using the `render()` function."
    void contextEnhancer(Request req, Response resp, JMap<JString,Object> context);
    
    void builder(Builder b);
    
    value loader = FileLoader();
    
    "The Pebble engine."
    shared PebbleEngine engine {
        value b = Builder().loader(loader);
        builder(b);
        return b.build();
    }
    
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
