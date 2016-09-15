import ceylon.html {
    Element
}
import ceylon.http.server {
    Request,
    Response
}

import com.github.bjansen.gyokuro.core {
    AnyTemplate
}
import com.github.bjansen.gyokuro.view.api {
    TemplateRenderer
}

shared alias HtmlTemplate => AnyTemplate<Element>;

shared class CeylonHtmlRenderer() satisfies TemplateRenderer<Element> {
    
    shared actual String render(Element template, Map<String,Anything> context, Request req, Response resp)
            => template.string;
    
}