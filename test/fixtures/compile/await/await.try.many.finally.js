const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(a, b, __ks_cb) {
		return __ks_cb(null, Operator.subtraction(a, b));
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
		let x = -1;
		let __ks_5 = () => {
			return __ks_cb(null, x);
		};
		let __ks_6 = () => {
			foo(33, x, (__ks_e, __ks_4) => {
				if(__ks_e) {
					__ks_5();
				}
				else {
					x = __ks_4;
					__ks_5();
				}
			});
		};
		let __ks_7 = (__ks_8) => {
			foo.__ks_0(2, 4, (__ks_e, __ks_0) => {
				if(__ks_e) {
					__ks_6();
				}
				else {
					x = __ks_0;
					__ks_6();
				}
			});
		};
		try {
			foo.__ks_0(42, 24, (__ks_e, __ks_1) => {
				if(__ks_e) {
					__ks_7(__ks_e);
				}
				else {
					try {
						foo.__ks_0(4, 2, (__ks_e, __ks_2) => {
							if(__ks_e) {
								__ks_7(__ks_e);
							}
							else {
								try {
									foo(__ks_1, __ks_2, (__ks_e, __ks_3) => {
										if(__ks_e) {
											__ks_7(__ks_e);
										}
										else {
											x = __ks_3;
											__ks_6();
										}
									});
								}
								catch(__ks_e) {
									return __ks_7(__ks_e);
								}
							}
						});
					}
					catch(__ks_e) {
						return __ks_7(__ks_e);
					}
				}
			});
		}
		catch(__ks_e) {
			__ks_7(__ks_e);
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
};