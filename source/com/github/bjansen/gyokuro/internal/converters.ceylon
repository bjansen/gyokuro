import ceylon.language.meta.declaration {
	OpenType,
	OpenClassOrInterfaceType
}
import ceylon.collection {
	ArrayList
}
import ceylon.language.meta {
	type
}

interface Converter<Type=String> {
	shared formal Boolean supports(OpenType type);
	shared formal Anything convert(OpenType type, Type str);
}

interface MultiConverter satisfies Converter<String[]> {

}

object primitiveTypesConverter satisfies Converter<> {
	
	value supportedTypes = [`class String`, `class Integer`, `class Float`, `class Boolean`].map((cls) => cls.openType);
	
	shared actual Anything convert(OpenType type, String str) {
		if (type == `class Integer`.openType) {
			return parseInteger(str);
		} else if (type == `class String`.openType) {
			return str;
		} else if (type == `class Float`.openType) {
			return parseFloat(str);
		} else if (type == `class Boolean`.openType) {
			if (str == "0") { return false; }
			if (str == "1") { return true; }

			return parseBoolean(str);
		}

		return null;
	}
	
	shared actual Boolean supports(OpenType type) => supportedTypes.contains(type);	
}

object listsConverter satisfies MultiConverter {
	
	shared actual Anything convert(OpenType t, String[] values) {
		if (is OpenClassOrInterfaceType t,
			t.declaration.qualifiedName == "ceylon.language::List") {
			assert(is OpenClassOrInterfaceType typeArg = t.typeArgumentList.first);
			
			if (!primitiveTypesConverter.supports(typeArg)) {
				throw BindingException("Only lists of primitive types are supported");
			}
			if (values.empty) {
				return empty;
			} else {
				value closedTypeArg = typeArg.declaration.apply<Anything>();
				value list = `class ArrayList`.instantiate([closedTypeArg]);

				for (val in values) {
					if (exists converted = primitiveTypesConverter.convert(typeArg, val)) {
						`function ArrayList.add`
								.memberApply<>(type(list))
								.bind(list).apply(converted);
					}
				}
				return list;
			}
		}

		return null;
	}
	
	shared actual Boolean supports(OpenType type) {
		if (is OpenClassOrInterfaceType type,
			type.declaration.qualifiedName == "ceylon.language::List") {
			return true;
		}
		return false;
	}
}

// TODO array, sequence, iterator, collections?

// TODO convert to a bean using reflection