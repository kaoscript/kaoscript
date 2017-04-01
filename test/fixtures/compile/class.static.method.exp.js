var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._color = "";
			this._type = "";
		}
		__ks_init() {
			Shape.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0(type, color) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(type === void 0 || type === null) {
				throw new TypeError("'type' is not nullable");
			}
			else if(!Type.isString(type)) {
				throw new TypeError("'type' is not of type 'String'");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			this._type = type;
			this._color = color;
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		static __ks_sttc_makeCircle_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			return new Shape("circle", color);
		}
		static makeCircle() {
			if(arguments.length === 1) {
				return Shape.__ks_sttc_makeCircle_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
		static __ks_sttc_makeRectangle_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			return new Shape("rectangle", color);
		}
		static makeRectangle() {
			if(arguments.length === 1) {
				return Shape.__ks_sttc_makeRectangle_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	let r = Shape.makeRectangle("black").toString();
}