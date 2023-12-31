const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isSchoolPerson: (value, cast) => Type.isDexObject(value, 1, 0, {kind: () => Helper.castEnum(value, "kind", PersonKind, cast), name: Type.isString})
	};
	const PersonKind = Helper.enum(Number, 0, "Director", 1, "Student", 2, "Teacher", 3);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		const student = Helper.assert(getStudent.__ks_0(), "\"SchoolPerson\"", 0, value => __ksType.isSchoolPerson(value, true));
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function getStudent() {
		return getStudent.__ks_rt(this, arguments);
	};
	getStudent.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.kind = PersonKind.Student;
			o.name = "John";
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