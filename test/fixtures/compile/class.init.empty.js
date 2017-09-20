module.exports = function() {
	class Foo {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0() {
		}
		__ks_cons(args) {
			if(args.length === 0) {
				Foo.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("wrong number of arguments");
			}
		}
	}
};