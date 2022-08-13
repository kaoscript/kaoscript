const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, values) {
		if(values === void 0) {
			values = null;
		}
		return 1;
	};
	foobar.__ks_1 = function(x, values) {
		if(values === void 0) {
			values = null;
		}
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isArray(value, Type.isString) || Type.isNull(value);
		const t2 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_0.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
			if(t2(args[0]) && t1(args[1])) {
				return foobar.__ks_1.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};