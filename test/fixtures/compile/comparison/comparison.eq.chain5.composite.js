const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b, c, d, e) {
		let __ks_0;
		if(a(5) === (__ks_0 = b(4)) && __ks_0 === (__ks_0 = c(3)) && __ks_0 === (__ks_0 = d(2)) && __ks_0 === e(1)) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 5) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3]) && t0(args[4])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3], args[4]);
			}
		}
		throw Helper.badArgs();
	};
};