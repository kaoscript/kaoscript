const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values, begin, end) {
		let __ks_0, __ks_1, __ks_2, __ks_3, __ks_4;
		__ks_0 = values();
		[__ks_1, __ks_2, __ks_3, __ks_4] = Helper.assertLoop(0, "", begin, "", end, __ks_0.length, "", 1);
		for(let __ks_5 = __ks_1, index, value; __ks_5 < __ks_2; __ks_5 += __ks_3) {
			index = __ks_4(__ks_5);
			value = __ks_0[index];
			console.log(index, value);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};