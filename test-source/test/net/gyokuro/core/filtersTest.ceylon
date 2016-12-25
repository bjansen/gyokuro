import ceylon.http.server {
    Request,
    Response,
    started
}
import ceylon.test {
    test,
    assertEquals
}

import net.gyokuro.core {
    clearRoutes,
    Application,
    get
}

import test.net.gyokuro.core.internal {
    request
}

test shared void testFilters() {
    clearRoutes();

    void filter1(Request req, Response resp, void next(Request req, Response resp)) {
        resp.writeString("beforeFilter1");
        next(req, resp);
        resp.writeString("afterFilter1");
    }
    void filter2(Request req, Response resp, void next(Request req, Response resp)) {
        resp.writeString("beforeFilter2");
        next(req, resp);
        resp.writeString("afterFilter2");
    }

    get("/filters", (req, resp) => resp.writeString("hello world"));

    value app = Application {
        port = 23456;
        filters = [filter1, filter2];
    };
    app.run((status) {
        if (status == started) {
            assertEquals(
                request("/filters"),
                "".join { "beforeFilter1", "beforeFilter2", "hello world", "afterFilter2", "afterFilter1" }
            );
            app.stop();
        }
    });
}
