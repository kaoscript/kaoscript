var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Greetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._message = "Hello!";
		}
		__ks_init() {
			Greetings.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
		}
		__ks_cons_1(message) {
			if(message === undefined || message === null) {
				throw new Error("Missing parameter 'message'");
			}
			if(!Type.isString(message)) {
				throw new Error("Invalid type for parameter 'message'");
			}
			this._message = message;
		}
		__ks_cons_2(number) {
			if(number === undefined || number === null) {
				throw new Error("Missing parameter 'number'");
			}
			if(!Type.isNumber(number)) {
				throw new Error("Invalid type for parameter 'number'");
			}
			Greetings.prototype.__ks_cons.call(this, [number]);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Greetings.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				if(Type.isString(args[0])) {
					Greetings.prototype.__ks_cons_1.apply(this, args);
				}
				else {
					Greetings.prototype.__ks_cons_2.apply(this, args);
				}
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
	}
	Greetings.__ks_reflect = {
		inits: 1,
		constructors: [
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
						type: "Number",
						min: 1,
						max: 1
					}
				]
			}
		],
		destructors: 0,
		instanceVariables: {
			_message: {
				access: 1,
				type: "String"
			}
		},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
}