import com.github.bjansen.gyokuro {
	controller,
	route
}

route("param")
controller class ParameterBinding() {
	
	route("f1")
	shared String func1(String string) {
		return string;
	}

	route("f2")
	shared String func2(Boolean boolean, Integer integer) {
		return boolean.string + integer.string;
	}

	route("f3")
	shared String func3(Boolean b1, Boolean b2, Boolean b3, Boolean b4) {
		return b1.string + b2.string + b3.string + b4.string;
	}
	
	route("f4")
	shared String func4(Float f1, Float f2, Float f3) {
		return f1.string + f2.string + f3.string;
	}
	
	route("f5")
	shared String func5(String s1, String? s2) {
		return "``s1``e``s2 else "flip"``";
	}
	
	route("f6")
	shared String func6(String s1, Integer i = 4, String s2 = "ever") {
		return s1 + i.string + s2;
	}
	
	route("hello/:who")
	shared String hello(String who) => "Hello, ``who``!";
}