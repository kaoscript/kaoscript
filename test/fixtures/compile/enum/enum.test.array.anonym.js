var Helper = require("@kaoscript/runtime").Helper;
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
		__ks_init_0() {
			this._colors = [];
		}
		__ks_init() {
			Foobar.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_color_0(index) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(index === void 0 || index === null) {
				throw new TypeError("'index' is not nullable");
			}
			return this._colors[index];
		}
		color() {
			if(arguments.length === 1) {
				return Foobar.prototype.__ks_func_color_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	function quxbaz(f, x) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(f === void 0 || f === null) {
			throw new TypeError("'f' is not nullable");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(Helper.valueOf(f.color(x)) === Color.Red.value) {
		}
	}
};