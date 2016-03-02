import ceylon.file {
	parsePath,
	Directory,
	Nil
}

import com.github.bjansen.gyokuro.clientgen {
	generateClient
}

"Run the module `gyokuro.demo.clientgen`."
shared void run() {
    value path = "./demos";
    value output = parsePath(path).resource;

    Directory dir;
    if (is Directory output) {
        dir = output;
    } else if (is Nil output) {
        dir = output.createDirectory(true);
    } else {
        print("Can't write to ``path``");
        return;
    }

    generateClient("/rest", `package gyokuro.demo.rest`, "gyokuro.demo.restclient", dir);

    print("Generation done.");
}

class FilsDeCaneton() {
	
}
FilsDeCaneton filsDeCanard = FilsDeCaneton();