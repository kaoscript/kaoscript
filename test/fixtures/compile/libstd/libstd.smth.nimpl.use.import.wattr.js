require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = require("./.libstd.smth.nimpl.use.export.ks.j5k8r9.ksb")().__ks_Object;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		echo(__ks_Object.__ks_sttc_length_0(value));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Object,
		echo,
		foobar
	};
};