import net.gyokuro.core {
    route,
    controller
}

route("lists")
controller object listBinding {

    route("list")
    shared String list(List<String> strings) {
        return strings.reduce((String partial, String element) => partial + element)
            else "empty";
    }

    route("list2")
    shared String list2(List<Boolean> bools, List<Integer> ints) {
        return "".join(bools.chain(ints).map((_) => _.string));
    }

    route("sequential")
    shared String sequential([Integer*] ints) {
        return "".join(ints.map((_) => _.string));
    }

    route("sequence")
    shared String sequence([Integer+] ints) {
        return "".join(ints.map((_) => _.string));
    }
}