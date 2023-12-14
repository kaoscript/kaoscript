const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPerson: value => Type.isDexObject(value, 1, 0, {name: Type.isString}),
		isSchoolPerson: (value, filter) => __ksType.isPerson(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
			if((variant = PersonKind(variant)) === null) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === PersonKind.Director) {
				return Type.isDexObject(value, 0, 0, {favorites: value => Type.isArray(value, value => __ksType.isSchoolPerson(value, value => value === PersonKind.Student)) || __ksType.isSchoolPerson(value, value => value === PersonKind.Teacher) || Type.isNull(value)});
			}
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
};