const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const __ks_rt = (...args) => {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[1])) {
					return __ks_rt.__ks_0.call(this, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = (x, y) => {
			if(x === void 0) {
				x = null;
			}
			return [x, y];
		};
		return __ks_rt;
	})();
};