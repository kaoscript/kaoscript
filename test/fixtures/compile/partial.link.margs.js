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
				throw new Error("Wrong number of arguments");
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