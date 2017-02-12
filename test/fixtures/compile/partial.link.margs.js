var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
	Shape.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
	let name = "draw";
	let shape = "rectangle";
	let color = "blue";
	function draw(shape, color, canvas) {
		if(arguments.length < 3) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(shape === void 0 || shape === null) {
			throw new TypeError("'shape' is not nullable");
		}
		if(color === void 0 || color === null) {
			throw new TypeError("'color' is not nullable");
		}
		if(canvas === void 0 || canvas === null) {
			throw new TypeError("'canvas' is not nullable");
		}
		return "I'm drawing a " + color + " " + shape + ".";
	}
	Helper.newInstanceMethod({
		class: Shape,
		name: name,
		function: draw,
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