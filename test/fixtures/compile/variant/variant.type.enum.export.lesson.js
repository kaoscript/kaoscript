const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isSchoolPerson: (value, cast, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
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
		}}),
		isGroup: (value, cast) => Type.isDexObject(value, 1, 0, {name: Type.isString, students: value => Type.isArray(value, value => __ksType.isSchoolPerson(value, cast, value => value === PersonKind.Student))}),
		isLesson: (value, cast) => Type.isDexObject(value, 1, 0, {name: Type.isString, teacher: value => __ksType.isSchoolPerson(value, cast, value => value === PersonKind.Teacher), students: value => __ksType.isGroup(value, cast) || Type.isArray(value, value => __ksType.isSchoolPerson(value, cast, value => value === PersonKind.Student))})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	return {
		PersonKind,
		__ksType: [__ksType.isSchoolPerson, __ksType.isGroup, __ksType.isLesson]
	};
};