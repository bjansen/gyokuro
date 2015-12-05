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
import ceylon.language.meta.model {
	ClassOrInterface
}
import ceylon.net.http.server {
	UploadedFile
}

interface Converter<Type=String> {
	shared formal Boolean supports(OpenType type);
	shared formal Anything convert(OpenType type, Type str);
}

interface MultiConverter satisfies Converter<Object[]> {

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
	
	value supportedTypes = [`List<>`, `Sequential<>`, `Sequence<>`]
			.map((_) => _.declaration.qualifiedName);
	
	shared actual Anything convert(OpenType t, Object[] values) {
		if (exists typeArg = getTypeArgument(t)) {
			assert(is OpenClassOrInterfaceType t);

			if (!primitiveTypesConverter.supports(typeArg)
				&& typeArg != `UploadedFile`.declaration.openType) {
				throw BindingException("Only lists of primitive types or
				                        UploadedFile are supported");
			}
			value closedTypeArg = typeArg.declaration.apply<Anything>();
			value tName = t.declaration.qualifiedName;

			if (values.empty) {
				if (tName == `Sequence<>`.declaration.qualifiedName) {
					throw BindingException("Cannot bind empty array to nonempty sequence");
				}
				return empty;
			} else if (tName == `List<>`.declaration.qualifiedName) {
				return convertList(closedTypeArg, values, typeArg);
			} else {
				return convertSequence(closedTypeArg, values, typeArg);
			}
		}

		return null;
	}
	
	shared actual Boolean supports(OpenType type) {
		if (is OpenClassOrInterfaceType type,
			supportedTypes.contains(type.declaration.qualifiedName)) {
			return true;
		}
		return false;
	}

	shared OpenClassOrInterfaceType? getTypeArgument(OpenType t) {
		if (is OpenClassOrInterfaceType t,
			supportedTypes.contains(t.declaration.qualifiedName),
			is OpenClassOrInterfaceType typeArg = t.typeArgumentList.first) {

			return typeArg;
		}
		
		return null;
	}
	
	Anything convertList(ClassOrInterface<Anything> closedTypeArg, Object[] values, OpenClassOrInterfaceType typeArg) {
		value list = `class ArrayList`.instantiate([closedTypeArg]);
		for (val in values) {
			value converted = switch(val)
			case (is String) primitiveTypesConverter.convert(typeArg, val)
			case (is UploadedFile) val
			else null;
			
			if (exists converted) {
				`function ArrayList.add`
						.memberApply<>(type(list))
						.bind(list).apply(converted);
			}
		}
		return list;
	}

	Anything convertSequence(ClassOrInterface<Anything> closedTypeArg, Object[] values, OpenClassOrInterfaceType typeArg) {
		if (is Object list = convertList(closedTypeArg, values, typeArg)) {
			return `function ArrayList.sequence`
					.memberApply<>(type(list))
					.bind(list).apply();
		}
		return null;
	}
}

// TODO convert to a bean using reflection