var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.is(x, ClassA)) {
			throw new TypeError("'x' is not of type 'ClassA'");
		}
	}
	class ClassZ {
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
		static __ks_sttc_foo_0(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.is(x, ClassA)) {
				throw new TypeError("'x' is not of type 'ClassA'");
			}
		}
		static foo() {
			if(arguments.length === 1) {
				return ClassZ.__ks_sttc_foo_0.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	class ClassA {
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
	}
};