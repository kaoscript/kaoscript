var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Shape = Helper.class({
		$name: "Shape",
		$static: {
			__ks_destroy_0: function(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				that._color = null;
			},
			__ks_destroy: function(that) {
				Shape.__ks_destroy_0(that);
			}
		},
		$create: function() {
			this._color = "black";
			this.__ks_cons(arguments);
		},
		__ks_cons_0: function(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
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
				throw new SyntaxError("wrong number of arguments");
			}
		},
		__ks_func_draw_0: function() {
			throw new Error("Not Implemented");
		},
		draw: function() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_draw_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	});
	var __ks_Shape = {};
	let Rectangle = Helper.class({
		$name: "Rectangle",
		$extends: Shape,
		$static: {
			__ks_destroy_0: function(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				that._foo = null;
			},
			__ks_destroy: function(that) {
				Shape.__ks_destroy(that);
				Rectangle.__ks_destroy_0(that);
			}
		},
		__ks_init_1: function() {
			this._foo = "bar";
		},
		__ks_init: function() {
			Shape.prototype.__ks_init.call(this);
			Rectangle.prototype.__ks_init_1.call(this);
		},
		__ks_cons_0: function(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			Shape.prototype.__ks_cons.call(this, [color]);
		},
		__ks_cons: function(args) {
			if(args.length === 1) {
				Rectangle.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		},
		__ks_func_draw_0: function() {
			return "I'm drawing a " + this._color + " rectangle.";
		},
		draw: function() {
			if(arguments.length === 0) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this);
			}
			return Shape.prototype.draw.apply(this, arguments);
		}
	});
}