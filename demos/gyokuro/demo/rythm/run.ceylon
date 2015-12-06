import com.github.bjansen.gyokuro.core {
    render,
    Application,
    Template,
    get
}
import com.github.bjansen.gyokuro.view.rythm {
    RythmRenderer
}

"Run the module `gyokuro.demo.rythm`."
shared void run() {
    
    get("/hello", `hello`);
    
    Application {
        renderer = RythmRenderer("demos-assets/rythm/", ".rythm");
    }.run();
}

Template hello() => render("hello", map({ "who"->"World" }));
