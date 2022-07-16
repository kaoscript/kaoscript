const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = (() => {
		const __ks_rt = (...args) => {
			const t0 = Type.isNumber;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return __ks_rt.__ks_0.call(null, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = function(a, b) {
			return a - b;
		};
		return __ks_rt;
	})();
};