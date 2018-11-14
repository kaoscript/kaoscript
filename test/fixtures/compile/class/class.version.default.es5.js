var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Rectangle = Helper.class({
		$name: "Rectangle",
		$version: [1, 0, 0],
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init: function() {
		},
		__ks_cons_0: function(color) {
			if(color === void 0 || color === null) {
				color = "black";
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			this._color = color;
		},
		__ks_cons: function(args) {
			if(args.length >= 0 && args.length <= 1) {
				Rectangle.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		},
		__ks_func_draw_0: function(canvas) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(canvas === void 0 || canvas === null) {
				throw new TypeError("'canvas' is not nullable");
			}
			return "I'm drawing a " + this._color + " rectangle.";
		},
		draw: function() {
			if(arguments.length === 1) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	});
	console.log(Rectangle.name);
	console.log(Rectangle.version);
};