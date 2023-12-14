require("kaoscript/register");
const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	var {PersonKind, __ksType: __ksType0} = require("./.variant.type.enum.export.nullable.ks.j5k8r9.ksb")();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.kind = PersonKind.Student;
			o.name = "John";
			o.mainRoom = (() => {
				const o = new OBJ();
				o.name = "ABC";
				return o;
			})();
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};