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
		__ks_func_draw_0() {
			return "I'm drawing a " + this._color + " rectangle.";
		}
		draw() {
			if(arguments.length === 0) {
				return Shape.prototype.__ks_func_draw_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		static __ks_sttc_makeBlue_0() {
			return new Shape("blue");
		}
		static makeBlue() {
			if(arguments.length === 0) {
				return Shape.__ks_sttc_makeBlue_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
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
			draw: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			]
		},
		classMethods: {
			makeBlue: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			]
		}
	};
	var __ks_Shape = {};
	Class.newClassMethod({
		class: Shape,
		name: "makeRed",
		final: __ks_Shape,
		function: function() {
			return new Shape("red");
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: [
			]
		}
	});
	let shape = Shape.makeBlue();
	console.log(shape.draw());
	shape = __ks_Shape._cm_makeRed();
	console.log(shape.draw());
}