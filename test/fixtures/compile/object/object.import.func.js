require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = require("./.object.export.func.ks.j5k8r9.ksb")().Foobar;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(f) {
		return f.foo();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Foobar.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		Foobar
	};
};