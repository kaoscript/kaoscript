const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	foobar.__ks_1 = function(a) {
		return 1;
	};
	foobar.__ks_2 = function(a) {
		return 2;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_2.call(that, args[0]);
			}
			return foobar.__ks_0.call(that, Array.from(args));
		}
		return foobar.__ks_0.call(that, Array.from(args));
	};
};