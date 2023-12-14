const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}),
		isSchoolPerson: (value, filter) => __ksType.isPosition(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
			if((variant = PersonKind(variant)) === null) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant === PersonKind.Student) {
				return Type.isDexObject(value, 0, 0, {name: Type.isString});
			}
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	return {
		PersonKind,
		__ksType: [__ksType.isPosition, __ksType.isSchoolPerson]
	};
};