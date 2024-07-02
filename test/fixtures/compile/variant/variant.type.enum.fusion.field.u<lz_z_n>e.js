const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	const Person = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString}));
	const SchoolPerson = Helper.alias(value => Person.is(value) && Type.isDexObject(value, 1, 0, {favorite: value => Type.isArray(value, SchoolPerson.is) || SchoolPerson.is(value) || Type.isNull(value)}));
};