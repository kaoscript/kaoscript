var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._items = [];
		}
		__ks_init() {
			Foobar.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_list_0(fn) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(fn === void 0 || fn === null) {
				throw new TypeError("'fn' is not nullable");
			}
			else if(!Type.isFunction(fn)) {
				throw new TypeError("'fn' is not of type 'Function'");
			}
			return Helper.mapArray(this._items, (item) => {
				return fn(this._name, item);
			});
		}
		list() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_list_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};