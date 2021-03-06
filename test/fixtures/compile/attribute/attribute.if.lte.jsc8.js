var __ks__ = require("@kaoscript/runtime");
var Helper = __ks__.Helper, Type = __ks__.Type;
module.exports = function() {
	var Shape = Helper.class({
		$name: "Shape",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init_0: function() {
			this._color = "";
		},
		__ks_init: function() {
			Shape.prototype.__ks_init_0.call(this);
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
		}
	});
	Shape.prototype.__ks_func_draw_trident_0 = function(canvas) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(canvas === void 0 || canvas === null) {
			throw new TypeError("'canvas' is not nullable");
		}
		return "I'm drawing a " + this._color + " rectangle.";
	};
	Shape.prototype.draw_trident = function() {
		if(arguments.length === 1) {
			return Shape.prototype.__ks_func_draw_trident_0.apply(this, arguments);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};