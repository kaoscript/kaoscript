const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		for(let __ks_1 = 0, __ks_0 = values.length, line, element; __ks_1 < __ks_0; ++__ks_1) {
			({line, element} = values[__ks_1]);
			console.log(element);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, element: Type.isString}));
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};