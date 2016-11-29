import net.gyokuro.transform.api {
    Transformer
}
import com.google.gson {
    GsonBuilder
}
import ceylon.interop.java {
    javaClass
}

shared class GsonTransformer() satisfies Transformer {
    
    shared GsonBuilder gson = GsonBuilder();
    
    shared actual [String+] contentTypes => [
        "application/json", "application/javascript"
    ];
    
    shared actual Instance deserialize<Instance>(String serialized)
            given Instance satisfies Object
            => gson.create().fromJson(serialized, javaClass<Instance>());
    
    shared actual String serialize(Object o)
            => gson.create().toJson(o);
}
