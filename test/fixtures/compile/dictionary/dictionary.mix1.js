const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = (() => {
			const d = new Dictionary();
			d.qux = (() => {
				const __ks_rt = (...args) => {
					if(args.length === 0) {
						return __ks_rt.__ks_0.call(null);
					}
					throw Helper.badArgs();
				};
				__ks_rt.__ks_0 = function() {
					let i = 1;
				};
				return __ks_rt;
			})();
			return d;
		})();
		return d;
	})();
};