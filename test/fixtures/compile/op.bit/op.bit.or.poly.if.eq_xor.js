const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(r1, r2, g1, g2, b1, b2) {
		if(((r1 ^ r2) | (g1 ^ g2) | (b1 ^ b2)) === 0) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 6) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3]) && t0(args[4]) && t0(args[5])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3], args[4], args[5]);
			}
		}
		throw Helper.badArgs();
	};
};