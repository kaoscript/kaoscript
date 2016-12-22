var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Person {
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
				Person.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_height_0() {
			return this._float;
		}
		__ks_func_height_1(height) {
			if(height === undefined || height === null) {
				throw new Error("Missing parameter 'height'");
			}
			if(!Type.isNumber(height)) {
				throw new Error("Invalid type for parameter 'height'");
			}
			this._height = height;
			return this;
		}
		height() {
			if(arguments.length === 0) {
				return Person.prototype.__ks_func_height_0.apply(this);
			}
			else if(arguments.length === 1) {
				return Person.prototype.__ks_func_height_1.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Person.__ks_reflect = {
		inits: 0,
		constructors: [
			{
				access: 3,
				min: 0,
				max: 0,
				parameters: []
			}
		],
		destructors: 0,
		instanceVariables: {
			_height: {
				access: 1,
				type: "Number"
			}
		},
		classVariables: {},
		instanceMethods: {
			height: [
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
							type: "Number",
							min: 1,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {}
	};
}