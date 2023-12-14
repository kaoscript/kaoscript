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
			return true;
		}})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	function getStudent() {
		return getStudent.__ks_rt(this, arguments);
	};
	getStudent.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.kind = PersonKind.Student;
			o.name = "Richard";
			return o;
		})();
	};
	getStudent.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return getStudent.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};