import ceylon.net.http.server {
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
    
    route("talk")
    shared void makeDuckTalk(Response resp, Request req) {
        resp.writeString("Quack world!");
    }
    
    route("actions")
    shared String[] listThingsDucksCanDo() {
        return ["fly", "quack", "eat", "dive"];
    }
    
    suppressWarnings("expressionTypeNothing")
    route("find")
    shared String findDuck(Integer id) {
        // If we can't find the duck in DB,
        // return a 404 response.
        return daoFind(id) else halt(404, "Duck not found");
    }
    
    String? daoFind(Integer id) => null;
}
