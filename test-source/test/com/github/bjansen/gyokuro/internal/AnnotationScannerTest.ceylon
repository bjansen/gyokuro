import ceylon.test {
	test,
	assertEquals
}

import com.github.bjansen.gyokuro.internal {
	annotationScanner
}

shared test void scanClass() {
	value controllers = annotationScanner.scanControllersInPackage("/",
		`package test.com.github.bjansen.gyokuro.internal.testdata`);
	
	value func = controllers.get("/cls/func");
	assert(exists func);
	value handler = func[1];
	assertEquals("func", handler.name);
	
	assert(exists otherfunc = controllers.get("/cls/otherfunc"));
}

shared test void scanPathWithSlashes() {
	value controllers = annotationScanner.scanControllersInPackage("/",
		`package test.com.github.bjansen.gyokuro.internal.testdata`);
	
	assert(exists otherfunc = controllers.get("/path/function"));	
}

shared test void scanControllerWithoutRoute() {
	value controllers = annotationScanner.scanControllersInPackage("/",
		`package test.com.github.bjansen.gyokuro.internal.testdata`);
	
	assert(exists func3 = controllers.get("/func3"));	
}