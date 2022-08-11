const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return 1;
	};
	foobar.__ks_1 = function(x) {
		return 2;
	};
	foobar.__ks_2 = function(x) {
		return 3;
	};
	foobar.__ks_3 = function(x) {
		return 4;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = value => Type.isArray(value, Type.isBoolean);
		const t2 = value => Type.isArray(value, Type.isNumber);
		const t3 = value => Type.isArray(value, Type.isString);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_3.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			if(t2(args[0])) {
				return foobar.__ks_2.call(that, args[0]);
			}
			if(t3(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};