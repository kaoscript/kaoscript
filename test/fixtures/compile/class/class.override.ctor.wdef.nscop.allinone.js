var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons_1(x) {
			if(x === void 0 || x === null) {
				x = "";
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Foobar.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				Foobar.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	class Quxbaz extends Foobar {
		__ks_init() {
			Foobar.prototype.__ks_init.call(this);
		}
		__ks_cons_0(x) {
			if(x === void 0 || x === null) {
				x = "";
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			Foobar.prototype.__ks_cons.call(this, []);
		}
		__ks_cons(args) {
			if(args.length >= 0 && args.length <= 1) {
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