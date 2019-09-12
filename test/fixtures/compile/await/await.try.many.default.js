var {Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo(x, y, __ks_cb) {
		if(arguments.length < 3) {
			let __ks_error = new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2 + 1)");
			if(arguments.length > 0 && Type.isFunction((__ks_cb = arguments[arguments.length - 1]))) {
				return __ks_cb(__ks_error);
			}
			else {
				throw __ks_error;
			}
		}
		else if(!Type.isFunction(__ks_cb)) {
			throw new TypeError("'callback' must be a function");
		}
		if(x === void 0 || x === null) {
			return __ks_cb(new TypeError("'x' is not nullable"));
		}
		if(y === void 0 || y === null) {
			return __ks_cb(new TypeError("'y' is not nullable"));
		}
		return __ks_cb(null, Operator.subtraction(x, y));
	}
	function bar(__ks_cb) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 0 + 1)");
		}
		else if(!Type.isFunction(__ks_cb)) {
			throw new TypeError("'callback' must be a function");
		}
		let d, e;
		let __ks_2 = () => {
			return __ks_cb(null, Operator.multiplication(d, e));
		};
		let __ks_3 = (__ks_4) => {
			d = 0;
			e = 1;
			__ks_2();
		};
		try {
			foo(42, 24, (__ks_e, __ks_0) => {
				if(__ks_e) {
					__ks_3(__ks_e);
				}
				else {
					try {
						d = __ks_0;
						foo(4, 2, (__ks_e, __ks_1) => {
							if(__ks_e) {
								__ks_3(__ks_e);
							}
							else {
								e = __ks_1;
								__ks_2();
							}
						});
					}
					catch(__ks_e) {
						return __ks_3(__ks_e);
					}
				}
			});
		}
		catch(__ks_e) {
			__ks_3(__ks_e);
		}
	}
};