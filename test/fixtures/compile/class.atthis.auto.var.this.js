var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Greetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._message = "";
		}
		__ks_init() {
			Greetings.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0(message) {
			if(message === void 0 || message === null) {
				message = "Hello!";
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			this._message = message.toUpperCase();
		}
		__ks_cons(args) {
			if(args.length >= 0 && args.length <= 1) {
				Greetings.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_greet_0(name) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			return this._message + "\nIt's nice to meet you, " + name + ".";
		}
		greet() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_0.apply(this, arguments);
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
				max: 1,
				parameters: [
					{
						type: "String",
						min: 0,
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
		instanceMethods: {
			greet: [
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
			]
		},
		classMethods: {}
	};
	let hello = new Greetings("Hello world!");
	console.log(hello.greet("miss White"));
}