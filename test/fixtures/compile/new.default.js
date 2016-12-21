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
	}
	Foo.__ks_reflect = {
		inits: 0,
		constructors: [],
		instanceVariables: {},
		classVariables: {},
		instanceMethods: {},
		classMethods: {}
	};
	let foo = new Foo();
}