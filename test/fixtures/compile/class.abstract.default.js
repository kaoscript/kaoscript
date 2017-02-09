var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class AbstractGreetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._message = "";
		}
		__ks_init() {
			AbstractGreetings.prototype.__ks_init_1.call(this);
		}
		__ks_cons_0() {
			AbstractGreetings.prototype.__ks_cons.call(this, ["Hello!"]);
		}
		__ks_cons_1(message) {
			if(message === undefined || message === null) {
				throw new Error("Missing parameter 'message'");
			}
			else if(!Type.isString(message)) {
				throw new Error("Invalid type for parameter 'message'");
			}
			this._message = message;
		}
		__ks_cons(args) {
			if(args.length === 0) {
				AbstractGreetings.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				AbstractGreetings.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
	}
	AbstractGreetings.__ks_reflect = {
		abstract: true,
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
			_message: {
				access: 1,
				type: "String"
			}
		},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
	class Greetings extends AbstractGreetings {
		__ks_init() {
			AbstractGreetings.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			AbstractGreetings.prototype.__ks_cons.call(this, args);
		}
		__ks_func_greet_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this._message + "\nIt's nice to meet you, " + name + ".";
		}
		greet() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_0.apply(this, arguments);
			}
			else if(AbstractGreetings.prototype.greet) {
				return AbstractGreetings.prototype.greet.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Greetings.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 0,
		instanceVariables: {},
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