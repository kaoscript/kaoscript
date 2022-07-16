const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return 0;
	};
	foobar.__ks_1 = function(x) {
		return 1;
	};
	foobar.__ks_2 = function(x) {
		if(x === void 0) {
			x = null;
		}
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Date);
		const t1 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			return foobar.__ks_2.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};