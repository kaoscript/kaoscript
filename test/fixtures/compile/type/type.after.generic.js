var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class ClassZ {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(values) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(values === void 0 || values === null) {
				throw new TypeError("'values' is not nullable");
			}
			else if(!Type.isArray(values, ClassA)) {
				throw new TypeError("'values' is not of type 'Array'");
			}
		}
		__ks_cons(args) {
			if(args.length === 1) {
				ClassZ.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class ClassA {
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
};