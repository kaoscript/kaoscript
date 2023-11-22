const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(items, values) {
		let __ks_0 = items();
		for(let __ks_1 in __ks_0) {
			const item = __ks_0[__ks_1];
			let __ks_2 = values();
			for(let __ks_3 in __ks_2) {
				const value = __ks_2[__ks_3];
			}
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