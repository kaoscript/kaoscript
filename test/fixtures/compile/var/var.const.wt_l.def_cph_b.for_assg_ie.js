const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		let __ks_0, __ks_1, __ks_2, __ks_3;
		const values = (() => {
			const a = [];
			[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 0, "x", x, Infinity, "", 1);
			for(let __ks_4 = __ks_0, i; __ks_4 < __ks_1; __ks_4 += __ks_2) {
				i = __ks_3(__ks_4);
				a.push(false);
			}
			return a;
		})();
		let __ks_4, __ks_5, __ks_6, __ks_7;
		[__ks_4, __ks_5, __ks_6, __ks_7] = Helper.assertLoopBounds(0, "", 0, "x", x, Infinity, "", 1);
		for(let __ks_8 = __ks_4, i; __ks_8 < __ks_5; __ks_8 += __ks_6) {
			i = __ks_7(__ks_8);
			values[i] = Operator.power(x, 3);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};