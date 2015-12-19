import ceylon.interop.java {
    javaClass
}
import ceylon.language.meta {
    type,
    typeLiteral
}
"A transformer that can convert the body of a Request to an Object,
 or transform an Object to the body of a Response."
shared interface Transformer {
    "Trasnforms an object to a string that will be the body of a Response."
    shared formal String serialize(Object o);
    
    "Tranforms the body of a Request to an Object that can be passed to a Request handler."
    shared formal Instance deserialize<Instance>(String serialized)
            given Instance satisfies Object;
    
    "Specifies which MIME types this transformer supports."
    shared formal [String+] contentTypes;
}

shared class T() satisfies Transformer {
    shared actual [String+] contentTypes => nothing;
    
    shared actual Instance deserialize<Instance>(String serialized)
        given Instance satisfies Object { 
        value type = typeLiteral<Instance>();
        value clz = javaClass<Instance>();
        
        return clz.newInstance();
    }
    
    shared actual String serialize(Object o) => nothing;
    
    
}

shared void coin() {
    value returnType = `function a`.apply<>().type;
    value inst = T();
    value meth = `function T.deserialize`.memberApply<>(type(inst), returnType).bind(inst);
    print(meth.apply("Coin"));
    
    //print(T().deserialize<T>("Coin").string);
}

T a() => nothing;