const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPerson: value => Type.isDexObject(value, 1, 0, {name: Type.isString}),
		isSchoolPerson: value => __ksType.isPerson(value) && Type.isDexObject(value, 1, 0, {favorite: value => Type.isArray(value, __ksType.isSchoolPerson) || __ksType.isSchoolPerson(value) || Type.isNull(value)})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
};