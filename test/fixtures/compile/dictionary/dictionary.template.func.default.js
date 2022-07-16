const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let x = "y";
	let foo = (() => {
		const d = new Dictionary();
		d[x] = (() => {
			const __ks_rt = (...args) => {
				if(args.length === 0) {
					return __ks_rt.__ks_0.call(null);
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = function() {
				return 42;
			};
			return __ks_rt;
		})();
		return d;
	})();
};