const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Function = {};
	let fn = (() => {
		const __ks_rt = (...args) => {
			const t0 = Type.isString;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return __ks_rt.__ks_0.call(this, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = (prefix, name) => {
			return prefix + name;
		};
		return __ks_rt;
	})();
	fn = Function.curry(fn, "Hello ");
	console.log(Helper.toString(fn("White")));
};