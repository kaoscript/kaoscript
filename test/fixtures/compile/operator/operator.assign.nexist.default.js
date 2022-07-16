const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function qux() {
		return qux.__ks_rt(this, arguments);
	};
	qux.__ks_0 = function() {
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
		if(Type.isValue(__ks_0 = foo.__ks_0()) ? (bar = __ks_0, false) : true) {
			throw new Error();
		}
		console.log(foo, bar);
	};
	qux.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return qux.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};