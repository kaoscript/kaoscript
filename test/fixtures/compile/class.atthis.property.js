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
		__ks_func_message_0(message) {
			if(message === undefined || message === null) {
				throw new Error("Missing parameter 'message'");
			}
			this._message = message;
			return this;
		}
		__ks_func_message_1() {
			return this._message;
		}
		message() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_message_0.apply(this, arguments);
			}
			else if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_message_1.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_greet_01_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this._message + "\nIt's nice to meet you, " + name + ".";
		}
		greet_01() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_01_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_greet_02_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this.message() + "\nIt's nice to meet you, " + name + ".";
		}
		greet_02() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_02_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_greet_03_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this._message.toUpperCase() + "\nIt's nice to meet you, " + name + ".";
		}
		greet_03() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_03_0.apply(this, arguments);
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
				parameters: []
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
		destructors: 0,
		instanceVariables: {
			_message: {
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
							type: "Any",
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
			],
			greet_01: [
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
			greet_02: [
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
			greet_03: [
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
}