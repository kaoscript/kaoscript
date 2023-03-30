const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		const x = values[0];
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexArray(value, 2, 3, 0, 0, [Type.isNumber, Type.isString, Type.isBoolean]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};