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
		__ks_cons_0() {
			Greetings.prototype.__ks_cons.call(this, ["Hello!"]);
		}
		__ks_cons_1(message) {
			if(message === undefined || message === null) {
				throw new Error("Missing parameter 'message'");
			}
			this._message = message;
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Greetings.prototype.__ks_cons_0.apply(this);
			}
			else if(args.length === 1) {
				Greetings.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_greet_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(!(Type.isString(name) || Type.isNumber(name))) {
				throw new Error("Invalid type for parameter 'name'");
			}
			return this._message + "\nIt's nice to meet you, " + name + ".";
		}
		__ks_func_greet_1(person) {
			if(person === undefined || person === null) {
				throw new Error("Missing parameter 'person'");
			}
			if(!Type.is(person, Person)) {
				throw new Error("Invalid type for parameter 'person'");
			}
			this.greet(person.name());
		}
		greet() {
			if(arguments.length === 1) {
				if(Type.is(arguments[0], this.constructor.__ks_reflect.instanceMethods.greet[1].parameters[0].type)) {
					return Greetings.prototype.__ks_func_greet_1.apply(this, arguments);
				}
				else {
					return Greetings.prototype.__ks_func_greet_0.apply(this, arguments);
				}
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Greetings.__ks_reflect = {
		inits: 1,
		constructors: [
			{
				access: 3,
				min: 0,
				max: 0,
				parameters: [
				]
			},
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
		instanceVariables: {
			_message: {
				access: 1,
				type: "String"
			}
		},
		classVariables: {
		},
		instanceMethods: {
			greet: [
				{
					access: 3,
					min: 1,
					max: 1,
					parameters: [
						{
							type: ["String","Number"],
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
							type: Person,
							min: 1,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {
		}
	};
	let hello = new Greetings("Hello world!");
	console.log(hello.greet("miss White"));
}