module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_toString_0() {
			console.log("hello");
		}
		toString() {
			if(arguments.length === 0) {
				return Foo.prototype.__ks_func_toString_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	Foo.__ks_reflect = {
		inits: 0,
		constructors: [
		],
		instanceVariables: {
		},
		classVariables: {
		},
		instanceMethods: {
			toString: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				}
			]
		},
		classMethods: {
		}
	};
}