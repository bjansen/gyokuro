import ceylon.language.meta.declaration {
	OpenType
}

interface Converter {
	shared formal Boolean supports(OpenType type);
	shared formal Anything convert(OpenType type, String str);
}

object primitiveTypesConverter satisfies Converter {
	
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

// TODO array, sequence, iterator, collections?

// TODO convert to a bean using reflection