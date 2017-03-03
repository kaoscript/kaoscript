module.exports = function() {
	class Attribute {
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
	Attribute.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
	class ErrorAttribute extends Attribute {
		__ks_init() {
			Attribute.prototype.__ks_init.call(this);
		}
		__ks_cons_0(data) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(data === void 0 || data === null) {
				throw new TypeError("'data' is not nullable");
			}
			this._data = data;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				ErrorAttribute.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				Attribute.prototype.__ks_cons.call(this, args);
			}
		}
	}
	ErrorAttribute.__ks_reflect = {
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
		instanceVariables: {
			_data: {
				access: 1,
				type: "Any"
			}
		},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
}