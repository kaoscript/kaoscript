var Type = require("@kaoscript/runtime").Type;
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
		__ks_func_color_0() {
			return this._color;
		}
		__ks_func_color_1(color) {
			if(color === undefined || color === null) {
				throw new Error("Missing parameter 'color'");
			}
			if(!Type.isString(color)) {
				throw new Error("Invalid type for parameter 'color'");
			}
			this._color = color;
			return this;
		}
		__ks_func_color_2(shape) {
			if(shape === undefined || shape === null) {
				throw new Error("Missing parameter 'shape'");
			}
			if(!Type.is(shape, Shape)) {
				throw new Error("Invalid type for parameter 'shape'");
			}
			this._color = shape.color();
			return this;
		}
		color() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_color_0.apply(this);
			}
			else if(arguments.length === 1) {
				if(Type.isString(arguments[0])) {
					return Shape.prototype.__ks_func_color_1.apply(this, arguments);
				}
				else {
					return Shape.prototype.__ks_func_color_2.apply(this, arguments);
				}
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
			color: [
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
							type: "String",
							min: 1,
							max: 1
						}
					]
				},
				{
					access: 3,
					min: 1,
					max: 1,
					parameters: [
						{
							type: Shape,
							min: 1,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {}
	};
	let s = new Shape("#777");
	console.log(s.color());
}