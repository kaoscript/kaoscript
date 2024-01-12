const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(items) {
		return (() => {
			const a = [];
			for(let __ks_1 = 0, __ks_0 = items.length, key; __ks_1 < __ks_0; ++__ks_1) {
				Helper.assertDexArray(items[__ks_1], 1, 1, 0, 0, [Type.isValue]);
				([key] = items[__ks_1]);
				a.push(key);
			}
			return a;
		})();
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