var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._color = "";
		}
		__ks_init() {
			Shape.prototype.__ks_init_1.call(this);
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
		__ks_func_draw_0(shape, canvas) {
			if(shape === undefined || shape === null) {
				throw new Error("Missing parameter 'shape'");
			}
			if(canvas === undefined || canvas === null) {
				throw new Error("Missing parameter 'canvas'");
			}
			return "I'm drawing a " + this._color + " " + shape + ".";
		}
		draw() {
			if(arguments.length === 2) {
				return Shape.prototype.__ks_func_draw_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Shape.__ks_reflect = {
		inits: 1,
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
	let shape = "rectangle";
	Helper.newInstanceMethod({
		class: Shape,
		name: shape,
		method: "draw",
		arguments: [
			shape
		],
		signature: {
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
	});
}