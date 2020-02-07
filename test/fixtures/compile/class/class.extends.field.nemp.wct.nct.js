var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class ClassA {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			this._x = x;
			this._y = 0;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				ClassA.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class ClassB extends ClassA {
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			ClassA.prototype.__ks_cons.call(this, args);
		}
	}
};