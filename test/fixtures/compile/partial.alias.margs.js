var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Shape.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_draw_0(shape, color, canvas) {
			if(shape === undefined || shape === null) {
				throw new Error("Missing parameter 'shape'");
			}
			if(color === undefined || color === null) {
				throw new Error("Missing parameter 'color'");
			}
			if(canvas === undefined || canvas === null) {
				throw new Error("Missing parameter 'canvas'");
			}
			return "I'm drawing a " + color + " " + shape + ".";
		}
		draw() {
			if(arguments.length === 3) {
				return Shape.prototype.__ks_func_draw_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Shape.__ks_reflect = {
		inits: 0,
		constructors: [
			{
				access: 3,
				min: 0,
				max: 0,
				parameters: []
			}
		],
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {
			draw: [
				{
					access: 3,
					min: 3,
					max: 3,
					parameters: [
						{
							type: "Any",
							min: 3,
							max: 3
						}
					]
				}
			]
		},
		classMethods: {}
	};
	let shape = "rectangle";
	let color = "blue";
	Helper.newInstanceMethod({
		class: Shape,
		name: shape,
		method: "draw",
		arguments: [
			shape,
			color
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