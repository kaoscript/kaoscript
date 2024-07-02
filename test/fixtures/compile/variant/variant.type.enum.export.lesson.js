const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	const SchoolPerson = Helper.alias((value, cast, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
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
			return Type.isDexObject(value, 0, 0, {name: Type.isString});
		}
		return true;
	}}));
	const Group = Helper.alias((value, cast) => Type.isDexObject(value, 1, 0, {name: Type.isString, students: value => Type.isArray(value, value => SchoolPerson.is(value, cast, value => value === PersonKind.Student))}));
	const Lesson = Helper.alias((value, cast) => Type.isDexObject(value, 1, 0, {name: Type.isString, teacher: value => SchoolPerson.is(value, cast, value => value === PersonKind.Teacher), students: value => Group.is(value, cast) || Type.isArray(value, value => SchoolPerson.is(value, cast, value => value === PersonKind.Student))}));
	return {
		PersonKind,
		SchoolPerson,
		Group,
		Lesson
	};
};