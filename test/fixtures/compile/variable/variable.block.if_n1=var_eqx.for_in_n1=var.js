const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		let x, __ks_0;
		if((Type.isValue(__ks_0 = data()) ? (x = __ks_0, true) : false)) {
		}
		for(let __ks_3 = data(), __ks_2 = 0, __ks_1 = Helper.length(__ks_3), x; __ks_2 < __ks_1; ++__ks_2) {
			x = __ks_3[__ks_2];
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