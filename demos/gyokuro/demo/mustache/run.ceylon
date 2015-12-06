import com.github.bjansen.gyokuro.core {
    get,
    Application,
    Template,
    render
}
import com.github.bjansen.gyokuro.view.mustache {
    MustacheRenderer
}

"Run the module `gyokuro.demo.mustache`."
shared void run() {

    get("/hello", `hello`);
    
    Application {
        renderer = MustacheRenderer("demos-assets/mustache/", ".mustache");
    }.run();
}

Template hello() => render("hello", map({"who" -> "World"}));