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
			return Type.isDexObject(value, 0, 0, {name: Type.isString});
		}
		if(variant === PersonKind.Teacher) {
			return Type.isDexObject(value, 0, 0, {favorites: value => Type.isArray(value, value => SchoolPerson.is(value, cast))});
		}
		return true;
	}}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(person) {
		const persons = Helper.assert([person], "\"SchoolPerson(Student)[]\"", 0, value => Type.isArray(value, value => SchoolPerson.is(value, true, value => value === PersonKind.Student)));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};