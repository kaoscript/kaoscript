const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Argument = Helper.alias(value => Type.isNumber(value) || Type.isArray(value, Type.isNumber) || Type.isNull(value));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(argument) {
		if(argument === void 0) {
			argument = null;
		}
		if(!Type.isValue(argument)) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isArray(value, Type.isNumber) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};