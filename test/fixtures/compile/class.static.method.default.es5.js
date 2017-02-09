var __ks__ = require("@kaoscript/runtime");
var Helper = __ks__.Helper, Type = __ks__.Type;
module.exports = function() {
	let Shape = Helper.class({
		$name: "Shape",
		$static: {
			__ks_sttc_makeCircle_0: function(color) {
				if(color === undefined || color === null) {
					throw new Error("Missing parameter 'color'");
				}
				else if(!Type.isString(color)) {
					throw new Error("Invalid type for parameter 'color'");
				}
				return new Shape("circle", color);
			},
			makeCircle: function() {
				if(arguments.length === 1) {
					return Shape.__ks_sttc_makeCircle_0.apply(this, arguments);
				}
				throw new Error("Wrong number of arguments");
			},
			__ks_sttc_makeRectangle_0: function(color) {
				if(color === undefined || color === null) {
					throw new Error("Missing parameter 'color'");
				}
				else if(!Type.isString(color)) {
					throw new Error("Invalid type for parameter 'color'");
				}
				return new Shape("rectangle", color);
			},
			makeRectangle: function() {
				if(arguments.length === 1) {
					return Shape.__ks_sttc_makeRectangle_0.apply(this, arguments);
				}
				throw new Error("Wrong number of arguments");
			}
		},
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init_1: function() {
			this._color = "";
			this._type = "";
		},
		__ks_init: function() {
			Shape.prototype.__ks_init_1.call(this);
		},
		__ks_cons_0: function(type, color) {
			if(type === undefined || type === null) {
				throw new Error("Missing parameter 'type'");
			}
			else if(!Type.isString(type)) {
				throw new Error("Invalid type for parameter 'type'");
			}
			if(color === undefined || color === null) {
				throw new Error("Missing parameter 'color'");
			}
			else if(!Type.isString(color)) {
				throw new Error("Invalid type for parameter 'color'");
			}
			this._type = type;
			this._color = color;
		},
		__ks_cons: function(args) {
			if(args.length === 2) {
				Shape.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
	});
	Shape.__ks_reflect = {
		inits: 1,
		constructors: [
			{
				access: 3,
				min: 2,
				max: 2,
				parameters: [
					{
						type: "String",
						min: 2,
						max: 2
					}
				]
			}
		],
		destructors: 0,
		instanceVariables: {
			_color: {
				access: 1,
				type: "String"
			},
			_type: {
				access: 1,
				type: "String"
			}
		},
		classVariables: {},
		instanceMethods: {},
		classMethods: {
			makeCircle: [
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
			makeRectangle: [
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
			]
		}
	};
	let r = Shape.makeRectangle("black");
}