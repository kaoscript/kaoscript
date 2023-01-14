const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values, begin) {
		let __ks_0, __ks_1, __ks_2, __ks_3;
		[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoop(0, "", begin, "", Infinity, values.length, "", 1);
		for(let __ks_4 = __ks_0, __ks_5, value; __ks_4 < __ks_1; __ks_4 += __ks_2) {
			__ks_5 = __ks_3(__ks_4);
			value = values[__ks_5];
			console.log(value);
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