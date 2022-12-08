const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		return 0;
	};
	foobar.__ks_1 = function(x, y) {
		return 1;
	};
	foobar.__ks_2 = function(x, y, z) {
		if(z === void 0 || z === null) {
			z = 0;
		}
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isString(value) || Type.isObject(value);
		const t2 = Type.isString;
		const t3 = value => Type.isNumber(value) || Type.isString(value);
		const t4 = value => Type.isClassInstance(value, Date);
		const t5 = value => Type.isNumber(value) || Type.isString(value) || Type.isNull(value);
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t0(args[1])) {
					return foobar.__ks_2.call(that, args[0], args[1], void 0);
				}
				if(t1(args[1])) {
					return foobar.__ks_1.call(that, args[0], args[1]);
				}
				throw Helper.badArgs();
			}
			if(t2(args[0])) {
				if(t3(args[1])) {
					return foobar.__ks_2.call(that, args[0], args[1], void 0);
				}
				throw Helper.badArgs();
			}
			if(t4(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t3(args[0]) && t3(args[1]) && t5(args[2])) {
				return foobar.__ks_2.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};