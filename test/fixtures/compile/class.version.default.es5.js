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
				throw new Error("Wrong number of arguments");
			}
		},
		__ks_func_Rectangle_0: function(color) {
			if(color === undefined || color === null) {
				color = "black";
			}
			if(!Type.isString(color)) {
				throw new Error("Invalid type for parameter 'color'");
			}
			this._color = color;
		},
		Rectangle: function() {
			if(arguments.length >= 0 && arguments.length <= 1) {
				return Rectangle.prototype.__ks_func_Rectangle_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		},
		__ks_func_draw_0: function(canvas) {
			if(canvas === undefined || canvas === null) {
				throw new Error("Missing parameter 'canvas'");
			}
			return "I'm drawing a " + this._color + " rectangle.";
		},
		draw: function() {
			if(arguments.length === 1) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
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