import ceylon.http.server {
    Request,
    Response
}

import net.gyokuro.view.api {
    JavaTemplateRenderer
}
import com.github.mustachejava {
    DefaultMustacheFactory
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
 [Mustache.java](https://github.com/spullara/mustache.java) templating engine."
shared class MustacheRenderer(prefix = "", suffix = "", contextEnhancer = noop) 
        extends JavaTemplateRenderer(contextEnhancer) {

    "A prefix to be added before the template name."
    String prefix;
    
    "A suffix to be added after the template name."
    String suffix;
    
    "A callback that can add custom entries to the context before passing it to Mustache.
     Custom entries can be overriden by handlers using the `render()` function."
    void contextEnhancer(Request req, Response resp, JMap<JString,Object> context);

    value factory = DefaultMustacheFactory();
    
    shared actual String render(String templateName, Map<String,Anything> context,
        Request req, Response resp) {

        value mustache = factory.compile(prefix + templateName + suffix);
        value writer = StringWriter();
        
        value javaContext = wrapMap(context, req, resp);
        mustache.execute(writer, javaContext).flush();
        
        return writer.string;
    }
}
