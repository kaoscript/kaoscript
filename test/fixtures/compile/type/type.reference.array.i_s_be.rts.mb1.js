const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		return values[1];
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value) && Type.isNumber(value[0]) && Type.isString(value[1]) && Type.isBoolean(value[2]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};