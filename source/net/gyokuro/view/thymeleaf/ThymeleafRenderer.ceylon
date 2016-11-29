import ceylon.http.server {
    Request,
    Response
}

import net.gyokuro.view.api {
    JavaTemplateRenderer
}

import java.lang {
    JString=String
}
import java.util {
    JMap=Map,
    Locale
}

import org.thymeleaf {
    TemplateEngine
}
import org.thymeleaf.context {
    Context
}
import org.thymeleaf.templateresolver {
    FileTemplateResolver
}

"A [[net.gyokuro.view.api::TemplateRenderer]] based on the
 [Thymeleaf](http://www.thymeleaf.org/) templating engine."
shared class ThymeleafRenderer(prefix = null, suffix = null, contextEnhancer = noop)
        extends JavaTemplateRenderer(contextEnhancer) {
    
    "A prefix to be added before the template name."
    String? prefix;
    
    "A suffix to be added after the template name."
    String? suffix;
    
    "A callback that can add custom entries to the context before passing it to Thymeleaf.
     Custom entries can be overriden by handlers using the `render()` function."
    void contextEnhancer(Request req, Response resp, JMap<JString,Object> context);
    
    value resolver = FileTemplateResolver();
    
    "The Thymeleaf engine."
    shared TemplateEngine engine = TemplateEngine();
    
    resolver.prefix = prefix;
    resolver.suffix = suffix;
    engine.setTemplateResolver(resolver);
    
    shared actual String render(String templateName, Map<String,Anything> context,
        Request req, Response resp) {
        
        value jMap = wrapMap(context, req, resp);
        
        return engine.process(templateName, Context(Locale.default, jMap));
    }
}
