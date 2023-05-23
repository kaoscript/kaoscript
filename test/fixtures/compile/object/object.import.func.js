require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ksType0 = require("./.object.export.func.ks.j5k8r9.ksb")().__ksType;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(f) {
		return f.foo();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType0[0];
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		__ksType: [__ksType0[0]]
	};
};