const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.alias(value => Type.isNumber(value) || Type.isString(value) || Type.isArray(value, value => Type.isNumber(value) || Type.isString(value)) || Type.isNull(value));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		if(x === void 0) {
			x = null;
		}
		if(Type.isArray(x)) {
		}
		else if(Type.isNumber(x)) {
		}
		else if(Type.isString(x)) {
		}
		else {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isString(value) || Type.isArray(value, value => Type.isNumber(value) || Type.isString(value)) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};