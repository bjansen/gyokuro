import ceylon.file {
    parsePath,
    Directory,
    Nil
}

import net.gyokuro.report {
    GyokuroApiGenerator
}
"Run the module `gyokuro.demo.report`."
shared void run() {
    value output = "modules/reports/gyokuro/";
    value path = 
            let (p = parsePath(output).resource)
            if (is Directory p) then p
            else if (is Nil p) then p.createDirectory(true)
            else null;
    
    if (exists path) {
        GyokuroApiGenerator(`package gyokuro.demo.rest`, path).run();
    } else {
        print("Can't access directory " + output);
    }
}