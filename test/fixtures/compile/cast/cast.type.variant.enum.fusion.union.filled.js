const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	const Person = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString}));
	const SchoolPerson = Helper.alias((value, cast, filter) => Person.is(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
		if(cast) {
			if((variant = PersonKind(variant)) === null) {
				return false;
			}
			value["kind"] = variant;
		}
		else if(!Type.isEnumInstance(variant, PersonKind)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		if(variant === PersonKind.Student) {
			return Type.isDexObject(value, 0, 0, {age: Type.isNumber});
		}
		if(variant === PersonKind.Teacher) {
			return Type.isDexObject(value, 0, 0, {favorites: value => Type.isArray(value, value => SchoolPerson.is(value, cast, value => value === PersonKind.Student) || Parent.is(value, cast))});
		}
		return true;
	}}));
	const Parent = Helper.alias((value, cast) => Person.is(value) && Type.isDexObject(value, 1, 0, {children: value => Type.isArray(value, value => SchoolPerson.is(value, cast, value => value === PersonKind.Student))}));
};