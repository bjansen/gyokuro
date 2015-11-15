import ceylon.io {
	SocketAddress
}
import ceylon.net.http.client {
	Request
}
import ceylon.net.http.server {
	newServer,
	Status,
	started,
	Response
}
import ceylon.net.uri {
	Uri,
	Authority,
	Path,
	PathSegment,
	Parameter
}
import ceylon.test {
	test,
	assertEquals,
	assertTrue
}

import com.github.bjansen.gyokuro.internal {
	RequestDispatcher
}
import com.github.bjansen.gyokuro {
	get,
	halt
}

shared test
void testDispatcher() {
	value dispatcher =
			RequestDispatcher(
		["/", `package test.com.github.bjansen.gyokuro.internal.testdata`],
		(req, resp) => true)
		.endpoint();
	
	value server = newServer({ dispatcher });
	server.addListener(void(Status status) {
			if (status == started) {
				try {
					runTests();
				} finally {
					server.stop();
				}
			}
		});
	server.start(SocketAddress("127.0.0.1", 23456));
}

void runTests() {
	// single param
	assertEquals(request("/param/f1", { Parameter("string", "foo") }), "foo");
	
	// multiple params
	assertEquals(request("/param/f2",
			{ Parameter("boolean", "true"),
				Parameter("integer", "42") }), "true42");
	
	// booleans
	assertEquals(request("/param/f3",
			{ Parameter("b1", "true"),
				Parameter("b2", "1"),
				Parameter("b3", "false"),
				Parameter("b4", "0") }),
		"truetruefalsefalse");
	
	// floats
	assertEquals(request("/param/f4",
			{ Parameter("f1", "0"),
				Parameter("f2", "3.14159265359"),
				Parameter("f3", "-2.71828182") }),
		"0.03.14159265359-2.71828182");
	
	// optional types
	assertEquals(request("/param/f5",
			{ Parameter("s1", "stup") }),
		"stupeflip");
	
	// default values
	assertEquals(request("/param/f6",
			{ Parameter("s1", "Ceylon") }),
		"Ceylon4ever");
	assertEquals(request("/param/f6",
			{ Parameter("s1", "log"),
				Parameter("s2", "j") }),
		"log4j");
	assertEquals(request("/param/f6",
			{ Parameter("s1", "map"),
				Parameter("s2", "list"),
				Parameter("i", "2") }),
		"map2list");
	
	get("/myRoute", `myHandler`);
	assertEquals(request("/myRoute",
			{ Parameter("s1", "abc"),
				Parameter("i1", "123") }),
		"abc123");
	
	get("/testHalt", `testHalt`);
	assertTrue(request("/testHalt", {})
		.contains("500 - I can haz an error"));	
}

void myHandler(String s1, Integer i1, Response resp) {
	resp.writeString(s1 + i1.string);
}

void testHalt() {
	halt(500, "I can haz an error");
}

String request(String path, {Parameter*} params) {
	value segments = path.split('/'.equals, true, false)
		.filter((_) => !_.empty)
		.map((el) => PathSegment(el));
	value uri = Uri("http",
		Authority(null, null, "127.0.0.1", 23456, false),
		Path(true, *segments)
	);
	value request = Request {
		uri = uri;
		initialParameters = params;
	};
	
	value response = request.execute();
	
	return response.contents;
}
