const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		let __ks_0, __ks_1, __ks_2, __ks_3;
		for(let __ks_6 = (() => {
			const a = [];
			[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 0, "", values.length, Infinity, "", 1);
			for(let __ks_4 = __ks_0, i; __ks_4 < __ks_1; __ks_4 += __ks_2) {
				i = __ks_3(__ks_4);
				a.push(values[i].values());
			}
			return a;
		})(), __ks_5 = 0, __ks_4 = __ks_6.length, value; __ks_5 < __ks_4; ++__ks_5) {
			value = __ks_6[__ks_5];
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};