var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Shape = Helper.class({
		$name: "Shape",
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init: function() {
		},
		__ks_cons_0: function(color) {
			if(color === undefined || color === null) {
				throw new Error("Missing parameter 'color'");
			}
			else if(!Type.isString(color)) {
				throw new Error("Invalid type for parameter 'color'");
			}
			this._color = color;
		},
		__ks_cons: function(args) {
			if(args.length === 1) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		},
		__ks_func_draw_0: function() {
		},
		draw: function() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_draw_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
	});
	Shape.__ks_reflect = {
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
				}
			]
		},
		classMethods: {}
	};
	let Rectangle = Helper.class({
		$name: "Rectangle",
		$extends: Shape,
		__ks_init: function() {
			Shape.prototype.__ks_init.call(this);
		},
		__ks_cons_0: function(color) {
			if(color === undefined || color === null) {
				throw new Error("Missing parameter 'color'");
			}
			Shape.prototype.__ks_cons.call(this, [color]);
		},
		__ks_cons: function(args) {
			if(args.length === 1) {
				Rectangle.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				Shape.prototype.__ks_cons.call(this, args);
			}
		},
		__ks_func_draw_0: function() {
			return "I'm drawing a " + this._color + " rectangle.";
		},
		draw: function() {
			if(arguments.length === 0) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this);
			}
			return Shape.prototype.draw.apply(this, arguments);
		}
	});
	Rectangle.__ks_reflect = {
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
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {
			draw: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				}
			]
		},
		classMethods: {}
	};
	let r = new Rectangle("black");
	console.log(r.draw());
}