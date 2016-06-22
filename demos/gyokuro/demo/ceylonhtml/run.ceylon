import ceylon.html {
    Html,
    Head,
    Title,
    Body,
    Div
}

import com.github.bjansen.gyokuro.core {
    render,
    Application,
    get
}
import com.github.bjansen.gyokuro.view.ceylonhtml {
    CeylonHtmlRenderer,
    HtmlTemplate
}

"Run the module `gyokuro.demo.ceylonhtml`."
shared void run() {
    get("/hello", `hello`);
    
    Application {
        renderer = CeylonHtmlRenderer();
    }.run();
}

HtmlTemplate hello() {
    value html = Html {
        Head {
            Title { "Hello world" }
        },
        Body {
            Div {
                clazz = "mycls";
                children = {
                    "Hello from Ceylon HTML!"
                };
            }
        }
    };
    
    return render(html);
}
