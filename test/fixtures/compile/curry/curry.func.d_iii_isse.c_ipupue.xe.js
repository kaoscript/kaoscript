const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function add() {
		return add.__ks_rt(this, arguments);
	};
	add.__ks_0 = function(x, y, z) {
		return x + y + z;
	};
	add.__ks_1 = function(x, y, z) {
		return x;
	};
	add.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
		if(args.length === 3) {
			if(t0(args[0])) {
				if(t0(args[1])) {
					if(t0(args[2])) {
						return add.__ks_0.call(that, args[0], args[1], args[2]);
					}
					throw Helper.badArgs();
				}
				if(t1(args[1]) && t1(args[2])) {
					return add.__ks_1.call(that, args[0], args[1], args[2]);
				}
				throw Helper.badArgs();
			}
		}
		throw Helper.badArgs();
	};
	const addOne = Helper.curry((fn, ...args) => add(...args), (__ks_0, __ks_1) => add.__ks_0(1, __ks_0, __ks_1), (__ks_0, __ks_1) => add.__ks_1(1, __ks_0, __ks_1));
};