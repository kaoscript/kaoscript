const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function fib() {
		return fib.__ks_rt(this, arguments);
	};
	fib.__ks_0 = function([m, n]) {
		return [n, Operator.add(m, n)];
	};
	fib.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexArray(value, 1, 2, 0, 0, [Type.isValue, Type.isValue]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return fib.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const f = fib.__ks_0([1, 1]);
};