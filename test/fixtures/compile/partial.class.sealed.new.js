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
			else if(!Type.isString(color)) {
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
				}
			]
		},
		classMethods: {
			makeBlue: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				}
			]
		}
	};
	var __ks_Shape = {};
	Helper.newInstanceMethod({
		class: Shape,
		name: "makeRed",
		sealed: __ks_Shape,
		function: function() {
			this._color = "red";
			return this;
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	Helper.newClassMethod({
		class: Shape,
		name: "makeRed",
		sealed: __ks_Shape,
		function: function() {
			return new Shape("red");
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	console.log(new Shape().draw());
	console.log(__ks_Shape._im_makeRed(new Shape()).draw());
}