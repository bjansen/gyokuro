import ceylon.test {
    test,
    assertTrue
}

import net.gyokuro.core.internal {
    annotationScanner,
    router
}
import net.gyokuro.core {
    clearRoutes
}

shared test void scanClass() {
    clearRoutes();
    annotationScanner.scanControllersInPackage("/",
        `package test.net.gyokuro.core.internal.testdata`);

    assertTrue(router.canHandlePath("/cls/func"));
    //value func = rou.get("/cls/func");
    //assert(exists func);
    //value handler = func[1];
    //assertEquals("func", handler.name);
    //
    //assert(exists otherfunc = controllers.get("/cls/otherfunc"));
}

shared test void scanPathWithSlashes() {
    clearRoutes();
    annotationScanner.scanControllersInPackage("/",
        `package test.net.gyokuro.core.internal.testdata`);

    assertTrue(router.canHandlePath("/path/function"));
}

shared test void scanControllerWithoutRoute() {
    clearRoutes();
    annotationScanner.scanControllersInPackage("/",
        `package test.net.gyokuro.core.internal.testdata`);

    assertTrue(router.canHandlePath("/func3"));
}

shared test void scanObjectController() {
    clearRoutes();
    annotationScanner.scanControllersInPackage("/",
        `package test.net.gyokuro.core.internal.testdata`);

    assertTrue(router.canHandlePath("/obj/func4"));
}