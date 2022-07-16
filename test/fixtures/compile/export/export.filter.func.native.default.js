require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Function = require("../_/._function.ks.j5k8r9.ksb")().__ks_Function;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return (() => {
			const __ks_rt = (...args) => {
				if(args.length === 0) {
					return __ks_rt.__ks_0.call(this);
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = () => {
				return x;
			};
			return __ks_rt;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		foobar,
		__ks_Function
	};
};