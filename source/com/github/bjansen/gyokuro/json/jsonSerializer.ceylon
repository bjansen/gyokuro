import ceylon.json {
	Builder
}
import ceylon.language.meta {
	type
}
import ceylon.language.meta.declaration {
	ValueDeclaration
}

"A serializer that transforms anything to a valid JSON string"
shared object jsonSerializer {
	
	value maxDepth = 10;
	shared variable CustomSerializer[] customSerializers = [];
	
	"Transforms anything to a valid JSON string"
    shared String serialize(Anything obj) {
        value builder = Builder();

		visit(obj, builder, 1);
		
        return builder.result?.string else "";
    }

	void visit(Anything obj, Builder builder, Integer depth) {
		if (depth > maxDepth) {
			return;
		}
		
		if (exists obj) {
			for (serializer in customSerializers) {
				if (serializer.supports(obj)) {
					serializer.serialize(obj, builder);
					return;
				}
			}
		}
				
		switch (obj)
		case (is String) {
			visitString(obj, builder);
		}
		case (is Float) {
			visitNumber(obj, builder);
		}
		case (is Integer) {
			visitNumber(obj, builder);
		}
		case (is Sequential<Anything>) {
			visitSequence(obj, builder, depth + 1);
		}
		case (is Boolean) {
			visitBoolean(obj, builder);
		}
		case (is Null) {
			visitNull(builder);
		}
		else {
			visitObject(obj, builder, depth + 1);
		}
	}
	
    void visitSequence(Anything[] obj, Builder builder, Integer depth) {
        builder.onStartArray();
        
        for (item in obj) {
            visit(item, builder, depth + 1);
        }
        
        builder.onEndArray();
    }

    void visitObject(Object obj, Builder builder, Integer depth) {
        value model = type(obj);

		builder.onStartObject();

		for (ValueDeclaration decl in model.declaration.memberDeclarations<ValueDeclaration>()) {
            value name = decl.name;
            
            if (name.equals("hash") || name.equals("string")) {
                continue;
            }
			
            builder.onKey(name);
			
            visit(decl.memberGet(obj), builder, depth + 1);
        }
        
        builder.onEndObject();
    }
    
    void visitString(String str, Builder builder) {
        builder.onString(str);
    }
    
    void visitNumber(Float|Integer number, Builder builder) {
        builder.onNumber(number);
    }
    
    void visitBoolean(Boolean boolean, Builder builder) {
        builder.onBoolean(boolean);
    }
    
    void visitNull(Builder builder) {
        builder.onNull();
    }
}

"Handles the serialization of a custom type"
shared interface CustomSerializer {
	
	"Adds the object's serialized representation to a Builder"
	shared formal void serialize(Object obj, Builder builder);
	
	"Checks if this serializer can serialize a given object"
	shared formal Boolean supports(Object obj);
}