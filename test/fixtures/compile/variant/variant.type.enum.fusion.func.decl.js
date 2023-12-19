const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPerson: value => Type.isDexObject(value, 1, 0, {name: Type.isString}),
		isSchoolPerson: (value, cast, filter) => __ksType.isPerson(value) && Type.isDexObject(value, 1, 0, {kind: variant => {
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
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(person) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isSchoolPerson;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};