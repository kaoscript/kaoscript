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
		__ks_cons: function(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		},
		__ks_func_Rectangle_0: function(color) {
			if(color === void 0 || color === null) {
				color = "black";
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			this._color = color;
		},
		Rectangle: function() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Rectangle.prototype.__ks_func_Rectangle_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
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
	Rectangle.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {
			_color: {
				access: 1,
				type: "String"
			}
		},
		classVariables: {},
		instanceMethods: {
			Rectangle: [
				{
					access: 3,
					min: 0,
					max: 1,
					parameters: [
						{
							type: "String",
							min: 0,
							max: 1
						}
					]
				}
			],
			draw: [
				{
					access: 3,
					min: 1,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {}
	};
	console.log(Rectangle.name);
	console.log(Rectangle.version);
}