module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
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
	}
	Shape.__ks_reflect = {
		final: true,
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
		instanceVariables: {
			_color: {
				access: 1,
				type: "String"
			}
		},
		classVariables: {
		},
		instanceMethods: {
		},
		classMethods: {
		}
	};
	var __ks_Shape = {};
	Class.newInstanceMethod({
		class: Shape,
		name: "draw",
		final: __ks_Shape,
		function: function(shape) {
			if(shape === undefined || shape === null) {
				throw new Error("Missing parameter 'shape'");
			}
			return "I'm drawing a " + this._color + " " + shape + ".";
		},
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
	return {
		console: console,
		Shape: Shape,
		__ks_Shape: __ks_Shape
	};
}