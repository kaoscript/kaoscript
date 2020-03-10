require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var Foobar = require("./class.override.ctor.wdef.wscop.warg.master.ks")().Foobar;
	class Quxbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons_0(x, y) {
			if(x === void 0 || x === null) {
				x = "";
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
			Foobar.prototype.__ks_cons.call(this, []);
		}
		__ks_cons(args) {
			if(args.length >= 0 && args.length <= 2) {
				Quxbaz.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	return {
		Foobar: Foobar,
		Quxbaz: Quxbaz
	};
};