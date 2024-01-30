const {Helper} = require("@kaoscript/runtime");
const {__ksStd_types} = require("./.libstd.regex.decl.ks.j5k8r9.ksb")();
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksStd_types[0];
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};