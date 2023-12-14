const {Helper, OBJ, Type} = require("@kaoscript/runtime");
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
	function greeting() {
		return greeting.__ks_rt(this, arguments);
	};
	greeting.__ks_0 = function(person) {
		let __ks_0;
		if(person.kind === PersonKind.Teacher) {
			__ks_0 = "Hey Professor!";
		}
		else if(person.kind === PersonKind.Director) {
			__ks_0 = "Hello Director.";
		}
		else if(person.kind === PersonKind.Student && person.name === "Richard") {
			__ks_0 = "Still here Ricky?";
		}
		else if(person.kind === PersonKind.Student) {
			__ks_0 = "Hey, " + person.name + ".";
		}
		return __ks_0;
	};
	greeting.__ks_rt = function(that, args) {
		const t0 = __ksType.isSchoolPerson;
		if(args.length === 1) {
			if(t0(args[0])) {
				return greeting.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	console.log(greeting.__ks_0((() => {
		const o = new OBJ();
		o.kind = PersonKind.Student;
		o.name = "Richard";
		return o;
	})()));
};