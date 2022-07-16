const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b, c, d, e, f, g, h, i, j) {
		if(Operator.lt(a, b) && Operator.lte(b, c) && Operator.lt(c, d) && d === e && Operator.gt(e, f) && Operator.gte(f, g) && g === h && Operator.lt(h, i) && i !== j) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 10) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3]) && t0(args[4]) && t0(args[5]) && t0(args[6]) && t0(args[7]) && t0(args[8]) && t0(args[9])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(1, 2, 2, 3, 3, 2, 1, 1, 3, 5);
};