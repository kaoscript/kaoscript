const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b = null, e) {
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
		const t2 = value => Type.isString(value) || Type.isNull(value);
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], void 0, args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[0]) && t2(args[1]) && t1(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};