module.exports = function() {
	const foo = t1 + ((t2 - t1) * ((2 / 3) - t3) * 6);
	const bar = h + ((1 / 3) * -(i - 1));
	class Color {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	Color.registerSpace({
		"name": "FBQ",
		"formatters": {
			foo(t1, t2, t3) {
				if(arguments.length < 3) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
				}
				if(t1 === void 0 || t1 === null) {
					throw new TypeError("'t1' is not nullable");
				}
				if(t2 === void 0 || t2 === null) {
					throw new TypeError("'t2' is not nullable");
				}
				if(t3 === void 0 || t3 === null) {
					throw new TypeError("'t3' is not nullable");
				}
				return t1 + ((t2 - t1) * ((2 / 3) - t3) * 6);
			},
			bar(h, i) {
				if(arguments.length < 2) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(h === void 0 || h === null) {
					throw new TypeError("'h' is not nullable");
				}
				if(i === void 0 || i === null) {
					throw new TypeError("'i' is not nullable");
				}
				return h + ((1 / 3) * -(i - 1));
			}
		}
	});
	return {
		Color: Color
	};
};