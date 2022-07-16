const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return "otto";
		};
		return __ks_rt;
	})();
	let bar, __ks_0;
	Type.isValue(__ks_0 = foo.__ks_0()) ? bar = __ks_0 : null;
	console.log(foo, bar);
};