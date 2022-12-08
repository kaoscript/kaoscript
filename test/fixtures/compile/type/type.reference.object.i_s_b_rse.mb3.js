const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		const x = values.d;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isObject(value, Type.isString, {a: Type.isNumber, b: Type.isString, c: Type.isBoolean});
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};