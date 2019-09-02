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
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		static __ks_destroy_0(that) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(that === void 0 || that === null) {
				throw new TypeError("'that' is not nullable");
			}
		}
		static __ks_destroy(that) {
			Foo.__ks_destroy_0(that);
		}
	}
	let foo = new Foo();
	Foo.__ks_destroy(foo);
	foo = void 0;
};