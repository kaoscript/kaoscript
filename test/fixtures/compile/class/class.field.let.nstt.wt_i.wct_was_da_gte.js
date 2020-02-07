module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(values) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(values === void 0 || values === null) {
				throw new TypeError("'values' is not nullable");
			}
			this._x = values.x, this._y = values.y;
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