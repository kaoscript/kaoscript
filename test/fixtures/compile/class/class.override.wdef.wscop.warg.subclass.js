require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var Foobar = require("./class.override.wdef.wscop.warg.master.ks")().Foobar;
	class Quxbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			Foobar.prototype.__ks_cons.call(this, args);
		}
		__ks_func_foobar_0(x, y) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			if(y === void 0 || y === null) {
				y = this.__ks_default_0_0(x);
			}
			else if(!Type.isString(y)) {
				throw new TypeError("'y' is not of type 'String'");
			}
			return y;
		}
		foobar() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Quxbaz.prototype.__ks_func_foobar_0.apply(this, arguments);
			}
			else if(Foobar.prototype.foobar) {
				return Foobar.prototype.foobar.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	return {
		Foobar: Foobar,
		Quxbaz: Quxbaz
	};
};