const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const NS = Helper.alias(value => Type.isNumber(value) || Type.isString(value));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, value => Type.isNumber(value) || Type.isString(value));
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};