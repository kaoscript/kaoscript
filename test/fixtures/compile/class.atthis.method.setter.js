var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Greetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this.__message = "";
		}
		__ks_init() {
			Greetings.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
			Greetings.prototype.__ks_cons.call(this, ["Hello!"]);
		}
		__ks_cons_1(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			this.message(message);
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Greetings.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				Greetings.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_message_0(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			this.__message = message;
			return this;
		}
		__ks_func_message_1() {
			return this.__message;
		}
		message() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_message_1.apply(this);
			}
			else if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_message_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
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
			}
		],
		destructors: 0,
		instanceVariables: {
			__message: {
				access: 1,
				type: "String"
			}
		},
		classVariables: {},
		instanceMethods: {
			message: [
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
					min: 0,
					max: 0,
					parameters: []
				}
			]
		},
		classMethods: {}
	};
}