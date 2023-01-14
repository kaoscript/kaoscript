const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		let __ks_0, __ks_1, __ks_2, __ks_3;
		[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoop(0, "x", x, "y", y, Infinity, "", 1);
		if(__ks_0 <= __ks_1) {
			for(let __ks_4 = __ks_0, i; __ks_4 <= __ks_1; __ks_4 += __ks_2) {
				i = __ks_3(__ks_4);
				return i;
			}
		}
		else {
			return -1;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};