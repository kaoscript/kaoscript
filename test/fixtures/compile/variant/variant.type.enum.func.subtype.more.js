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
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	function onlyStudentOrTeacher() {
		return onlyStudentOrTeacher.__ks_rt(this, arguments);
	};
	onlyStudentOrTeacher.__ks_0 = function(person) {
		if(person.kind === PersonKind.Teacher) {
			console.log("teacher");
		}
		else {
			console.log("student: " + person.name);
		}
	};
	onlyStudentOrTeacher.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isSchoolPerson(value, value => value === PersonKind.Student || value === PersonKind.Teacher);
		if(args.length === 1) {
			if(t0(args[0])) {
				return onlyStudentOrTeacher.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};