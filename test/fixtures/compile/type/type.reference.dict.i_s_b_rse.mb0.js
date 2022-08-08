const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		const x = values.a;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isDictionary(value) && Type.isNumber(value.a) && Type.isString(value.b) && Type.isBoolean(value.c);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};