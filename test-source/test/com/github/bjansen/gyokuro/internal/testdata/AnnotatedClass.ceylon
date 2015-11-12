import com.github.bjansen.gyokuro {
	route,
	controller
}
route("cls")
controller class AnnotatedClass() {
	
	route("func")
	shared String func() => "";
	
	route("otherfunc")
	shared String otherFunc() => "";
}

route("/path/")
controller class AnnotatedClass2() {
	
	route("/function")
	shared String func2() => "";
}

controller class AnnotatedClass3() {
	
	route("/func3")
	shared String func3() => "";
}
