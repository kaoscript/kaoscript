const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x, y, __ks_cb) {
		return __ks_cb(null, Operator.subtraction(x, y));
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isFunction;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t1(args[2])) {
				return foo.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function(cb) {
		let __ks_0 = (__ks_1) => {
			cb(0);
		};
		try {
			foo.__ks_0(42, 24, (__ks_e, __ks_2) => {
				if(__ks_e) {
					__ks_0(__ks_e);
				}
				else {
					try {
						let d = __ks_2;
						cb(d);
					}
					catch(__ks_e) {
						return __ks_0(__ks_e);
					}
				}
			});
		}
		catch(__ks_e) {
			__ks_0(__ks_e);
		}
	};
	bar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return bar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};