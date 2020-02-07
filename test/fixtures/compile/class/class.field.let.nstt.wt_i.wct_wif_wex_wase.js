module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(test) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(test === void 0 || test === null) {
				throw new TypeError("'test' is not nullable");
			}
			if(test === true) {
				throw new Error("failed");
			}
			else {
				this._x = 24;
			}
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Foobar.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
};