const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isSchoolPerson: (value, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
			if(!Type.isEnumInstance(variant, PersonKind)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === PersonKind.Teacher) {
				return Type.isDexObject(value, 0, 0, {favorite: value => __ksType.isSchoolPerson(value, value => value === PersonKind.Student)});
			}
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, "Director", 1, "Student", 2, "Teacher", 3);
};