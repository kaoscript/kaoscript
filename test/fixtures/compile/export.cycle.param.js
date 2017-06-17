var Type = require("@kaoscript/runtime").Type;
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
		__ks_func_equals_0(b) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(b === void 0 || b === null) {
				throw new TypeError("'b' is not nullable");
			}
			else if(!Type.is(b, Foo)) {
				throw new TypeError("'b' is not of type 'Foo'");
			}
		}
		equals() {
			if(arguments.length === 1) {
				return Foo.prototype.__ks_func_equals_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	return {
		Foo: Foo
	};
}