var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Shape {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(color) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			this._color = color;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_draw_0() {
		}
		draw() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_draw_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
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
	class Rectangle extends Shape {
		__ks_init() {
			Shape.prototype.__ks_init.call(this);
		}
		__ks_cons_0(color, backgroundColor) {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(color === void 0 || color === null) {
				throw new TypeError("'color' is not nullable");
			}
			else if(!Type.isString(color)) {
				throw new TypeError("'color' is not of type 'String'");
			}
			if(backgroundColor === void 0 || backgroundColor === null) {
				throw new TypeError("'backgroundColor' is not nullable");
			}
			this._backgroundColor = backgroundColor;
			Shape.prototype.__ks_cons.call(this, [color]);
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Rectangle.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				Shape.prototype.__ks_cons.call(this, args);
			}
		}
		__ks_func_draw_0() {
			return "I'm drawing a " + this._color + " rectangle.";
		}
		draw() {
			if(arguments.length === 0) {
				return Rectangle.prototype.__ks_func_draw_0.apply(this);
			}
			return Shape.prototype.draw.apply(this, arguments);
		}
	}
	Rectangle.__ks_reflect = {
		inits: 0,
		constructors: [
			{
				access: 3,
				min: 2,
				max: 2,
				parameters: [
					{
						type: "String",
						min: 1,
						max: 1
					},
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
			_backgroundColor: {
				access: 1,
				type: "Any"
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
	let r = new Rectangle("black");
	console.log(r.draw());
}