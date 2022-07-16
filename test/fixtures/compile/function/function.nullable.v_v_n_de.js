const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z, d) {
		if(z === void 0) {
			z = null;
		}
		if(d === void 0 || d === null) {
			d = 42;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = value => Type.isString(value) || Type.isNull(value);
		if(args.length >= 3 && args.length <= 4) {
			if(t0(args[0]) && t0(args[1]) && t1(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(42, 24, null);
};