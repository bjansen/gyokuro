import ceylon.language.meta {
    type,
    typeLiteral
}
import com.github.bjansen.gyokuro.transform.api {
    Transformer
}
import ceylon.language.meta.model {
    Type
}
import ceylon.language.meta.declaration {
    OpenClassType
}
shared void test() {

    assert(exists param = `fun`.declaration.parameterDeclarations.first);

    value tr = GsonTransformer();
    
    assert(is OpenClassType ot = param.openType);
    value t = ot.declaration.apply<>();
    
    if (exists meth = `Transformer`.getMethod<>("deserialize", t)) {
        value val = meth.bind(tr).apply("{\"name\": \"ffoo\"}");
        print(val);
    } else {
        print("not found");
    }
   
}

void fun(Employee emp) {
    
}

class Employee(shared String name) {
    
}