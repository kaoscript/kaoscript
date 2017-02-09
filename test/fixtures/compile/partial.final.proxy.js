var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Shape {
		constructor() {
			this._color = "";
			this.__ks_cons(arguments);
		}
		__ks_cons_0(color) {
			if(color === undefined || color === null) {
				throw new Error("Missing parameter 'color'");
			}
			else if(!Type.isString(color)) {
				throw new Error("Invalid type for parameter 'color'");
			}
			this._color = color;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_draw_0() {
			return "I'm drawing with a " + this._color + " pencil.";
		}
		__ks_func_draw_1(shape) {
			if(shape === undefined || shape === null) {
				throw new Error("Missing parameter 'shape'");
			}
			return "I'm drawing a " + this._color + " " + shape + ".";
		}
		draw() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_draw_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Shape.prototype.__ks_func_draw_1.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Shape.__ks_reflect = {
		sealed: true,
		inits: 0,
		constructors: [
			{
				access: 3,
				min: 1,
				max: 1,
				parameters: [
					{
						type: "String",
						min: 1,
						max: 1
					}
				]
			}
		],
		destructors: 0,
		instanceVariables: {
			_color: {
				access: 1,
				type: "String"
			}
		},
		classVariables: {},
		instanceMethods: {
			draw: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				},
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
	var __ks_Shape = {};
	Helper.newInstanceMethod({
		class: Shape,
		name: "draw",
		sealed: __ks_Shape,
		function: function(color, shape) {
			if(color === undefined || color === null) {
				throw new Error("Missing parameter 'color'");
			}
			if(shape === undefined || shape === null) {
				throw new Error("Missing parameter 'shape'");
			}
			return "I'm drawing a " + color + " " + shape + ".";
		},
		signature: {
			access: 3,
			min: 2,
			max: 2,
			parameters: [
				{
					type: "Any",
					min: 2,
					max: 2
				}
			]
		}
	});
	class Proxy {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(color) {
			if(color === undefined || color === null) {
				throw new Error("Missing parameter 'color'");
			}
			this._shape = new Shape(color);
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Proxy.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_draw_0() {
			return __ks_Shape._im_draw(this._shape);
		}
		__ks_func_draw_1(shape) {
			if(shape === undefined || shape === null) {
				throw new Error("Missing parameter 'shape'");
			}
			return __ks_Shape._im_draw(this._shape, shape);
		}
		__ks_func_draw_2(color, shape) {
			if(color === undefined || color === null) {
				throw new Error("Missing parameter 'color'");
			}
			if(shape === undefined || shape === null) {
				throw new Error("Missing parameter 'shape'");
			}
			return __ks_Shape._im_draw(this._shape, color, shape);
		}
		draw() {
			if(arguments.length === 0) {
				return Proxy.prototype.__ks_func_draw_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Proxy.prototype.__ks_func_draw_1.apply(this, arguments);
			}
			else if(arguments.length === 2) {
				return Proxy.prototype.__ks_func_draw_2.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Proxy.__ks_reflect = {
		inits: 0,
		constructors: [
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
		],
		destructors: 0,
		instanceVariables: {
			_shape: {
				access: 1,
				type: Shape
			}
		},
		classVariables: {},
		instanceMethods: {
			draw: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				},
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
				},
				{
					access: 3,
					min: 2,
					max: 2,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 2
						}
					]
				}
			]
		},
		classMethods: {}
	};
	let shape = new Proxy("yellow");
	console.log(shape.draw("rectangle"));
	console.log(shape.draw("red", "rectangle"));
}