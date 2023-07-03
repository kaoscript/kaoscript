const {Helper, Operator, Type} = require("@kaoscript/runtime");
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
bar.__ks_0 = function(__ks_cb) {
	let d;
	let __ks_0 = (__ks_1) => {
		return __ks_cb(null, 0);
	};
	try {
		foo.__ks_0(42, 24, (__ks_e, __ks_2) => {
			if(__ks_e) {
				__ks_0(__ks_e);
			}
			else {
				try {
					d = __ks_2;
					console.log(d);
					return __ks_cb(null, Operator.multiplication(d, 3));
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
	const t0 = Type.isFunction;
	if(args.length === 1) {
		if(t0(args[0])) {
			return bar.__ks_0.call(that, args[0]);
		}
	}
	throw Helper.badArgs();
};
bar.__ks_0((__ks_e, __ks_0) => {
	console.log(__ks_0);
});