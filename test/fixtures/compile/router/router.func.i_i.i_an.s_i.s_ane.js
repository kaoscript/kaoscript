const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		return 0;
	};
	foobar.__ks_1 = function(x, y) {
		if(y === void 0) {
			y = null;
		}
		return 1;
	};
	foobar.__ks_2 = function(x, y) {
		return 2;
	};
	foobar.__ks_3 = function(x, y) {
		if(y === void 0) {
			y = null;
		}
		return 3;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0])) {
				if(t0(args[1])) {
					return foobar.__ks_0.call(that, args[0], args[1]);
				}
				return foobar.__ks_1.call(that, args[0], args[1]);
			}
			if(t1(args[0])) {
				if(t0(args[1])) {
					return foobar.__ks_2.call(that, args[0], args[1]);
				}
				return foobar.__ks_3.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};