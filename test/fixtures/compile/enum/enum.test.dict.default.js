var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._colors = new Dictionary();
		}
		__ks_init() {
			Foobar.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_isRed_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return Helper.valueOf(this._colors[name]) === Color.Red.value;
		}
		isRed() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_isRed_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};