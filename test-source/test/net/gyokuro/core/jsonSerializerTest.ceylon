import ceylon.test {
    test,
    assertEquals
}

import net.gyokuro.core.json {
    jsonSerializer
}

class MyClass() {
	shared variable Integer anInt = 1;
	shared variable String aString = "test";
	shared variable Float aFloat = 1.2345;
}

test void testSerializeObject() {
	value cls = MyClass();
	assertEquals(jsonSerializer.serialize(cls), "{\"aFloat\":1.2345,\"aString\":\"test\",\"anInt\":1}");
}

test void testSerializeSequence() {
	assertEquals(jsonSerializer.serialize([1,2,3,4]), "[1,2,3,4]");
	assertEquals(jsonSerializer.serialize([1.234,"2",MyClass(),4]), "[1.234,\"2\",{\"aFloat\":1.2345,\"aString\":\"test\",\"anInt\":1},4]");
	assertEquals(jsonSerializer.serialize([true, false, null]), "[true,false,null]");
}