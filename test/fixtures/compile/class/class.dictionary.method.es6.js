var {Dictionary, Operator} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
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
		__ks_func_xy_0() {
			return (() => {
				const d = new Dictionary();
				d.xy = this.xy(this._x, this._y);
				return d;
			})();
		}
		__ks_func_xy_1(x, y) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			return Operator.addOrConcat(x, y);
		}
		xy() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_xy_0.apply(this);
			}
			else if(arguments.length === 2) {
				return Foobar.prototype.__ks_func_xy_1.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};