require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var foo = require("../async/.async.export.default.ks.j5k8r9.ksb")().foo;
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function(__ks_cb) {
		foo.__ks_0(42, (__ks_e, __ks_0) => {
			if(__ks_e) {
				__ks_cb(__ks_e);
			}
			else {
				return __ks_cb(null, __ks_0);
			}
		});
	};
	bar.__ks_rt = function(that, args) {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return bar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};