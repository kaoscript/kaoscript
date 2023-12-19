const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isSchoolPerson: (value, cast, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
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
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	function greeting() {
		return greeting.__ks_rt(this, arguments);
	};
	greeting.__ks_0 = function(person) {
		if(person.kind === PersonKind.Student) {
			console.log(Helper.toString(person.name));
		}
	};
	greeting.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return greeting.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};