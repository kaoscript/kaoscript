const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		let line, element;
		for(let __ks_1 = 0, __ks_0 = values.length; __ks_1 < __ks_0; ++__ks_1) {
			Helper.assertDexObject(values[__ks_1], 1, 0, {line: Type.isValue, element: Type.isValue});
			({line, element} = values[__ks_1]);
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