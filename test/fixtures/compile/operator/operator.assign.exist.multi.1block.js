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
	let qux = (() => {
		const __ks_rt = (...args) => {
			if(args.length === 0) {
				return __ks_rt.__ks_0.call(this);
			}
			throw Helper.badArgs();
		};
		__ks_rt.__ks_0 = () => {
			return "itti";
		};
		return __ks_rt;
	})();
	let x, __ks_0;
	if(Type.isValue(__ks_0 = foo.__ks_0()) ? (x = __ks_0, true) : false) {
		console.log(x);
	}
	else if(Type.isValue(__ks_0 = qux.__ks_0()) ? (x = __ks_0, true) : false) {
		console.log(x);
	}
};