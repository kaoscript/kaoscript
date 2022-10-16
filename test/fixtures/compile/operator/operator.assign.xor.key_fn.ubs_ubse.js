const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(props, key, value) {
		let __ks_0;
		props[__ks_0 = key()] = Operator.xorBool(props[__ks_0], value);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isDictionary(value, value => Type.isBoolean(value) || Type.isString(value));
		const t1 = Type.isFunction;
		const t2 = value => Type.isBoolean(value) || Type.isString(value);
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t2(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};