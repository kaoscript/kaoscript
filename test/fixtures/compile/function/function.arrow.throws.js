const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const foobar = (() => {
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
			throw new Error();
		};
		return __ks_rt;
	})();
	return {
		foobar
	};
};