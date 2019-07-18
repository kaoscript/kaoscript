var Type = require("@kaoscript/runtime").Type;
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
		__ks_func_foobar_0() {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let __ks_class_1 = arguments[++__ks_i];
			if(__ks_class_1 === void 0) {
				__ks_class_1 = null;
			}
			else if(__ks_class_1 !== null && !Type.isString(__ks_class_1)) {
				throw new TypeError("'class' is not of type 'String'");
			}
			let __ks_default_1;
			if(arguments.length > 1 && (__ks_default_1 = arguments[++__ks_i]) !== void 0 && __ks_default_1 !== null) {
				if(!Type.isNumber(__ks_default_1)) {
					throw new TypeError("'default' is not of type 'Number'");
				}
			}
			else {
				__ks_default_1 = 0;
			}
			this._class = __ks_class_1;
			this._default = __ks_default_1;
			console.log(this._class, this._default);
		}
		foobar() {
			if(arguments.length >= 1 && arguments.length <= 2) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};