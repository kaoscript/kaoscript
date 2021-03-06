var {Dictionary, Type} = require("@kaoscript/runtime");
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
		static __ks_sttc_registerSpace_0(data) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(data === void 0 || data === null) {
				throw new TypeError("'data' is not nullable");
			}
		}
		static registerSpace() {
			if(arguments.length === 1) {
				return Color.__ks_sttc_registerSpace_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	Color.registerSpace((() => {
		const d = new Dictionary();
		d["name"] = "FBQ";
		d["formatters"] = (() => {
			const d = new Dictionary();
			d.foo = function(t1, t2, t3) {
				if(arguments.length < 3) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
				}
				if(t1 === void 0 || t1 === null) {
					throw new TypeError("'t1' is not nullable");
				}
				else if(!Type.isNumber(t1)) {
					throw new TypeError("'t1' is not of type 'Number'");
				}
				if(t2 === void 0 || t2 === null) {
					throw new TypeError("'t2' is not nullable");
				}
				else if(!Type.isNumber(t2)) {
					throw new TypeError("'t2' is not of type 'Number'");
				}
				if(t3 === void 0 || t3 === null) {
					throw new TypeError("'t3' is not nullable");
				}
				else if(!Type.isNumber(t3)) {
					throw new TypeError("'t3' is not of type 'Number'");
				}
				return t1 + ((t2 - t1) * ((2 / 3) - t3) * 6);
			};
			d.bar = function(h, i) {
				if(arguments.length < 2) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(h === void 0 || h === null) {
					throw new TypeError("'h' is not nullable");
				}
				else if(!Type.isNumber(h)) {
					throw new TypeError("'h' is not of type 'Number'");
				}
				if(i === void 0 || i === null) {
					throw new TypeError("'i' is not nullable");
				}
				else if(!Type.isNumber(i)) {
					throw new TypeError("'i' is not of type 'Number'");
				}
				return h + ((1 / 3) * -(i - 1));
			};
			return d;
		})();
		return d;
	})());
	return {
		Color: Color
	};
};