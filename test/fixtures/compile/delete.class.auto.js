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
		static __ks_destroy_0(that) {
			if(that === undefined || that === null) {
				throw new Error("Missing parameter 'that'");
			}
		}
		static __ks_destroy(that) {
			Foo.__ks_destroy_0(that);
		}
	}
	Foo.__ks_reflect = {
		inits: 0,
		constructors: [],
		destructors: 1,
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
	let foo = new Foo();
	Foo.__ks_destroy(foo);
	foo = undefined;
}