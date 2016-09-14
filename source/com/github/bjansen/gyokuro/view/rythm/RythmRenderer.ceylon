import ceylon.http.server {
    Request,
    Response
}

import com.github.bjansen.gyokuro.view.api {
    JavaTemplateRenderer
}

import java.lang {
    JString=String
}
import java.util {
    JMap=Map
}

import org.rythmengine {
    RythmEngine
}

"A [[com.github.bjansen.gyokuro.view.api::TemplateRenderer]] based on the 
 [Rythm](http://rythmengine.org/) templating engine."
shared class RythmRenderer(prefix = "", suffix = "", contextEnhancer = noop)
        extends JavaTemplateRenderer(contextEnhancer) {
    
    "A prefix to be used as the property `home.template`."
    String prefix;
    
    "A suffix to be added after the template name."
    String suffix;
    
    "A callback that can add custom entries to the context before passing it to Rythm.
     Custom entries can be overriden by handlers using the `render()` function."
    void contextEnhancer(Request req, Response resp, JMap<JString,Object> context);
    
    shared RythmEngine engine = RythmEngine();
    
    shared actual String render(String templateName, Map<String,Anything> context,
        Request req, Response resp) {
        
        value javaMap = wrapMap(context, req, resp);
        return engine.render(prefix + templateName + suffix, javaMap);
    }
}
