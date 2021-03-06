var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Shape = Helper.class({
		$name: "Shape",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init: function() {
		},
		__ks_cons_0: function(color) {
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
		},
		__ks_cons: function(args) {
			if(args.length === 1) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		},
		__ks_func_pen_0: function() {
			return "I'm drawing with a " + this._color + " pen.";
		},
		pen: function() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_pen_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
	let Rectangle = Helper.class({
		$name: "Rectangle",
		$extends: Shape,
		__ks_init: function() {
			Shape.prototype.__ks_init.call(this);
		},
		__ks_cons: function(args) {
			Shape.prototype.__ks_cons.call(this, args);
		},
		__ks_func_draw_0: function() {
			return Shape.prototype.pen.apply(this, []) + " I'm drawing a " + this._color + " rectangle.";
		},
		draw: function() {
			if(arguments.length === 0) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this);
			}
			else if(Shape.prototype.draw) {
				return Shape.prototype.draw.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	});
	let r = new Rectangle("black");
	console.log(r.draw());
};