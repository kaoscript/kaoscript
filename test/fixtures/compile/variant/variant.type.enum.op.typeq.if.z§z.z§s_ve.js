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
			if(variant === PersonKind.Student) {
				return Type.isDexObject(value, 0, 0, {name: Type.isString});
			}
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, "Director", 1, "Student", 2, "Teacher", 3);
	PersonKind.__ks_eq_ClassMember = value => value === PersonKind.Student || value === PersonKind.Teacher;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(person) {
		if(person.kind === PersonKind.Student && (person.name === "arthur")) {
			console.log(person.name);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isSchoolPerson(value, PersonKind.__ks_eq_ClassMember);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};