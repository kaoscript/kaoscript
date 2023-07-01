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
		if(args.length === 0) {
			return fn[0]();
		}
		throw Helper.badArgs();
	}, () => add.__ks_0(1, 2, 3));
};