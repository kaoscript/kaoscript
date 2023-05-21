const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function fib() {
		return fib.__ks_rt(this, arguments);
	};
	fib.__ks_0 = function(m, n) {
		return [n, Operator.add(m, n)];
	};
	fib.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fib.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	let __ks_0, __ks_1, __ks_2, __ks_3;
	const f = (__ks_0 = (__ks_1 = (__ks_2 = (__ks_3 = [1, 1], fib.__ks_0(__ks_3[0], __ks_3[1])), fib(...__ks_2)), fib(...__ks_1)), fib(...__ks_0));
};