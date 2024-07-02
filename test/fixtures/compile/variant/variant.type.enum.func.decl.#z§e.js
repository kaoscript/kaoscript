const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	const SchoolPerson = Helper.alias((value, cast, filter) => Type.isDexObject(value, 1, 0, {kind: variant => {
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
	}}));
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