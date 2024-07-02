require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Data = require("./.implement.type.imth.o<i>.export.ks.j5k8r9.ksb")().Data;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		__ks_Data.__ks_func_debug_0(data);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Data.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		Data
	};
};