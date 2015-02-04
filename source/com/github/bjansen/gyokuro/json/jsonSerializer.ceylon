import ceylon.json { Builder }
import ceylon.language.meta { type }
import ceylon.language.meta.declaration {
	ValueDeclaration
}

"A serializer that transforms anything to a valid JSON string"
shared object jsonSerializer {
	
	"Transforms anything to a valid JSON string"
    shared String serialize(Anything obj) {
        value builder = Builder();

		visit(obj, builder);
		
        return builder.result.string;
    }

	void visit(Anything obj, Builder builder) {
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
			visitSequence(obj, builder);
		}
		case (is Boolean) {
			visitBoolean(obj, builder);
		}
		case (is Null) {
			visitNull(builder);
		}
		else {
			visitObject(obj, builder);
		}
	}
	
    void visitSequence(Anything[] obj, Builder builder) {
        builder.onStartArray();
        
        for (item in obj) {
            visit(item, builder);
        }
        
        builder.onEndArray();
    }

    void visitObject(Object obj, Builder builder) {
        value model = type(obj);

		builder.onStartObject();

		for (ValueDeclaration decl in model.declaration.memberDeclarations<ValueDeclaration>()) {
            value name = decl.name;
            
            if (name.equals("hash") || name.equals("string")) {
                continue;
            }
			
            builder.onKey(name);
			
            visit(decl.memberGet(obj), builder);
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

