require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {PersonKind, SchoolPerson} = require("./.variant.type.enum.export.default.ks.j5k8r9.ksb")();
	function Student() {
		return Student.__ks_rt(this, arguments);
	};
	Student.__ks_0 = function(name) {
		return (() => {
			const o = new OBJ();
			o.kind = PersonKind.Student;
			o.name = name;
			return o;
		})();
	};
	Student.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return Student.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};