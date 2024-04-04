const {Helper, Type} = require("@kaoscript/runtime");
const {__ksStd_a} = require("./.libstd.array.decl.ks.j5k8r9.ksb")();
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		const values = [];
		__ksStd_a._im_push(values, {T: Type.isNumber}, x);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};