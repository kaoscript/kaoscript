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
			if(!Type.isString(color)) {
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
	let shape = new Shape("yellow");
	console.log(__ks_Shape._im_draw(shape, "rectangle"));
	console.log(__ks_Shape._im_draw(shape, "red", "rectangle"));
}