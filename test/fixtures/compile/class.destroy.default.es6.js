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
		__ks_cons_1(message = null) {
			this._message = message;
		}
		__ks_cons(args) {
			if(args.length >= 0 && arguments.length <= 1) {
				Greetings.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		static __ks_destroy_0(that) {
			if(that === undefined || that === null) {
				throw new Error("Missing parameter 'that'");
			}
			that._message = null;
		}
		static __ks_destroy(that) {
			Greetings.__ks_destroy_0(that);
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
				min: 0,
				max: 1,
				parameters: [
					{
						type: "Any",
						min: 0,
						max: 1
					}
				]
			}
		],
		destructors: 1,
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
}