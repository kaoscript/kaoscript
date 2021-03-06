var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Shape {
		constructor() {
			this._color = "";
			this.__ks_cons(arguments);
		}
		__ks_cons_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			this._color = color;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_draw_0() {
			return "I'm drawing a " + this._color + " rectangle.";
		}
		draw() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_draw_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		static __ks_sttc_makeBlue_0() {
			return new Shape("blue");
		}
		static makeBlue() {
			if(arguments.length === 0) {
				return Shape.__ks_sttc_makeBlue_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	var __ks_Shape = {};
	__ks_Shape.__ks_func_makeRed_0 = function() {
		this._color = "red";
		return this;
	};
	__ks_Shape.__ks_sttc_makeRed_0 = function() {
		return new Shape("red");
	};
	__ks_Shape._im_makeRed = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Shape.__ks_func_makeRed_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	__ks_Shape._cm_makeRed = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 0) {
			return __ks_Shape.__ks_sttc_makeRed_0();
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	console.log((new Shape("blue")).draw());
	console.log(__ks_Shape._im_makeRed(new Shape("blue")).draw());
};