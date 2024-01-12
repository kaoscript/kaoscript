const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(items) {
		return (() => {
			const a = [];
			for(let __ks_0 in items) {
				Helper.assertDexObject(items[__ks_0], 1, 0, {key: Type.isValue});
				const {key} = items[__ks_0];
				a.push(key);
			}
			return a;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};