var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Greetings = Helper.class({
		$name: "Greetings",
		$static: {
			__ks_destroy_0: function(that) {
				if(that === undefined || that === null) {
					throw new Error("Missing parameter 'that'");
				}
				that._message = null;
			},
			__ks_destroy: function(that) {
				Greetings.__ks_destroy_0(that);
			}
		},
		$create: function() {
			this.__ks_init();
			this.__ks_cons(arguments);
		},
		__ks_init_1: function() {
			this._message = "";
		},
		__ks_init: function() {
			Greetings.prototype.__ks_init_1.call(this);
		},
		__ks_cons_0: function() {
			Greetings.prototype.__ks_cons.call(this, ["Hello!"]);
		},
		__ks_cons_1: function(message = null) {
			this._message = message;
		},
		__ks_cons: function(args) {
			if(args.length >= 0 && arguments.length <= 1) {
				Greetings.prototype.__ks_cons_1.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		},
		__ks_func_greet_0: function(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			return this._message + "\nIt's nice to meet you, " + name + ".";
		},
		greet: function() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_greet_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	});
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