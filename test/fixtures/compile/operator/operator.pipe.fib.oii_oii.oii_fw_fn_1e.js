const {Helper, OBJ, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function fib() {
		return fib.__ks_rt(this, arguments);
	};
	fib.__ks_0 = function({m, n}) {
		return (() => {
			const o = new OBJ();
			o.m = n;
			o.n = Operator.add(m, n);
			return o;
		})();
	};
	fib.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexObject(value, 1, 0, {m: Type.isValue, n: Type.isValue});
		if(args.length === 1) {
			if(t0(args[0])) {
				return fib.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const f = fib.__ks_0((() => {
		const o = new OBJ();
		o.m = 1;
		o.n = 1;
		return o;
	})());
};