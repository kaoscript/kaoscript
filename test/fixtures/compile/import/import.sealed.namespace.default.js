require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var {Math, __ks_Math} = require("../export/.export.sealed.namespace.default.ks.j5k8r9.ksb")();
	const __ks_Math = {};
	__ks_Math.pi = function() {
		return __ks_Math.pi.__ks_rt(this, arguments);
	};
	__ks_Math.pi.__ks_0 = function() {
		return 42;
	};
	__ks_Math.pi.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Math.pi.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Math.pi.__ks_0());
};