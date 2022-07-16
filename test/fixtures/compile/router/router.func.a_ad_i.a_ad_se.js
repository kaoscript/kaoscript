const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z) {
		if(y === void 0 || y === null) {
			y = 0;
		}
		return x.times(Operator.addOrConcat(y, z));
	};
	foobar.__ks_1 = function(x, y, z) {
		if(y === void 0 || y === null) {
			y = 0;
		}
		return Helper.concatString(x.times(y), z);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isNumber;
		const t2 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t1(args[1])) {
					return foobar.__ks_0.call(that, args[0], void 0, args[1]);
				}
				if(t2(args[1])) {
					return foobar.__ks_1.call(that, args[0], void 0, args[1]);
				}
				throw Helper.badArgs();
			}
			throw Helper.badArgs();
		}
		if(args.length === 3) {
			if(t0(args[0])) {
				if(t1(args[2])) {
					return foobar.__ks_0.call(that, args[0], args[1], args[2]);
				}
				if(t2(args[2])) {
					return foobar.__ks_1.call(that, args[0], args[1], args[2]);
				}
			}
		}
		throw Helper.badArgs();
	};
};