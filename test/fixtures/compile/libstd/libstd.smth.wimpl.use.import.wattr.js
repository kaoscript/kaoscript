require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
const {__ksStd_o} = require("./.libstd.smth.wimpl.decl.ks.j5k8r9.ksb")();
module.exports = function() {
	var __ks_Object = require("./.libstd.smth.wimpl.use.export.ks.j5k8r9.ksb")().__ks_Object;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		echo(__ksStd_o.__ks_sttc_length_0(value));
		echo(__ks_Object.__ks_sttc_key_0(value, 0));
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