const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function add() {
		return add.__ks_rt(this, arguments);
	};
	add.__ks_0 = function(x, y, z) {
		return x + y + z;
	};
	add.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return add.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	const addOne = Helper.curry((that, fn, ...args) => {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fn[0](args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}, (__ks_0, __ks_1) => add.__ks_0(__ks_0, 1, __ks_1));
};