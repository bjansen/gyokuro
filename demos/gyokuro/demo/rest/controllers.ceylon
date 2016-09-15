import ceylon.http.server {
    Response,
    Request
}

import com.github.bjansen.gyokuro.core {
    controller,
    route,
    halt
}

route("duck")
controller class SimpleRestController() {

    "Make the duck talk!"
    route("talk")
    shared void makeDuckTalk(Response resp, Request req) {
        resp.writeString("Quack world!");
    }
    
    "Lists all the things a duck can do."
    route("actions")
    shared String[] listThingsDucksCanDo() {
        return ["fly", "quack", "eat", "dive"];
    }
    
    "Tries to find a duck."
    suppressWarnings("expressionTypeNothing")
    route("find")
    shared String findDuck(Integer id) {
        // If we can't find the duck in DB,
        // return a 404 response.
        return daoFind(id) else halt(404, "Duck not found");
    }
    
    String? daoFind(Integer id) => null;
}
