module.exports = function() {
	var __ks_Error = {};
	class Exception extends Error {
		constructor() {
			super();
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(message) {
			if(message === undefined || message === null) {
				throw new Error("Missing parameter 'message'");
			}
			this.message = message;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				Exception.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				Error.prototype.constructor.call(this, args);
			}
		}
		static __ks_sttc_throw_0(message) {
			if(message === undefined || message === null) {
				throw new Error("Missing parameter 'message'");
			}
			throw new Exception(message);
		}
		static throw() {
			if(arguments.length === 1) {
				return Exception.__ks_sttc_throw_0.apply(this, arguments);
			}
			else if(Error.throw) {
				return Error.throw.apply(null, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Exception.__ks_reflect = {
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
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {
			throw: [
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
		}
	};
	try {
		Exception.throw("foobar");
	}
	catch(__ks_0) {
	}
}