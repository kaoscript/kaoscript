var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		return x;
	}
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons_1(x, y) {
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
		}
		__ks_default_0_0(x) {
			return foobar(x);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Foobar.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1 || args.length === 2) {
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