import com.github.bjansen.gyokuro {
	route,
	controller
}

route("lists")
controller class ListBinding() {
	
	route("list")
	shared String list(List<String> strings) {
		return strings.reduce((String partial, String element) => partial + element)
			else "empty";
	}
	
	route("list2")
	shared String list2(List<Boolean> bools, List<Integer> ints) {
		return "".join(bools.chain(ints).map((_) => _.string));
	}
}