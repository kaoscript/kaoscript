const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_SyntaxError = {};
	const foobar = (() => {
		const d = new Dictionary();
		d.corge = (() => {
			const __ks_rt = (...args) => {
				if(args.length === 0) {
					return __ks_rt.__ks_0.call(null);
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = function() {
				throw new SyntaxError();
			};
			return __ks_rt;
		})();
		return d;
	})();
};