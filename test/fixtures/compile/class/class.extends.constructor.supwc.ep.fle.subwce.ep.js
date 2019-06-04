var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
			Shape.prototype.__ks_cons.call(this, ["circle"]);
		}
		__ks_cons_1(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			this._name = name;
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Shape.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				Shape.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
	class Rectangle extends Shape {
		__ks_init() {
			Shape.prototype.__ks_init.call(this);
		}
		__ks_cons_0() {
			Shape.prototype.__ks_cons.call(this, ["rectangle"]);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Rectangle.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
	class Foobar extends Shape {
		__ks_init() {
			Shape.prototype.__ks_init.call(this);
		}
		__ks_cons_0() {
			Shape.prototype.__ks_cons.call(this, []);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Foobar.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
};