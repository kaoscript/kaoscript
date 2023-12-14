const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isSchoolPerson: (value, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
			if((variant = PersonKind(variant)) === null) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === PersonKind.Student) {
				return Type.isDexObject(value, 0, 0, {name: Type.isString});
			}
			if(variant === PersonKind.Teacher) {
				return Type.isDexObject(value, 0, 0, {students: value => Type.isArray(value, value => __ksType.isSchoolPerson(value, value => value === PersonKind.Student)) || Type.isNull(value)});
			}
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
};