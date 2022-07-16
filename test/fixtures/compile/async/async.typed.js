const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(bar, qux, __ks_cb) {
		return __ks_cb(null, "foobar");
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		const t2 = Type.isFunction;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t2(args[2])) {
				return foo.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};