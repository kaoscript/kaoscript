var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(color) {
			if(color === void 0 || color === null) {
				color = "black";
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			this._color = color;
		}
		__ks_cons(args) {
			if(args.length >= 0 && args.length <= 1) {
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
	Shape.prototype.__ks_func_name_0 = function() {
		return this._name;
	};
	Shape.prototype.__ks_func_name_1 = function(name) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(name === void 0) {
			name = null;
		}
		this._name = name;
		return this;
	};
	Shape.prototype.__ks_func_toString_0 = function() {
		return Helper.concatString("I'm drawing a ", this._color, " ", this._name, ".");
	};
	Shape.prototype.name = function() {
		if(arguments.length === 0) {
			return Shape.prototype.__ks_func_name_0.apply(this);
		}
		else if(arguments.length === 1) {
			return Shape.prototype.__ks_func_name_1.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	Shape.prototype.toString = function() {
		if(arguments.length === 0) {
			return Shape.prototype.__ks_func_toString_0.apply(this);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	const shape = Shape.makeBlue();
	console.log(shape.toString());
};