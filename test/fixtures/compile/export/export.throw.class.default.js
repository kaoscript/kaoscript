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
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_foo_0() {
		}
		foo() {
			if(arguments.length === 0) {
				return Foo.prototype.__ks_func_foo_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	return {
		Foo: Foo
	};
};