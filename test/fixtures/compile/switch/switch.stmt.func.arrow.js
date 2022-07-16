const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return (() => {
			const __ks_rt = (...args) => {
				const t0 = Type.isValue;
				if(args.length === 1) {
					if(t0(args[0])) {
						return __ks_rt.__ks_0.call(this, args[0]);
					}
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = (x) => {
			};
			return __ks_rt;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};