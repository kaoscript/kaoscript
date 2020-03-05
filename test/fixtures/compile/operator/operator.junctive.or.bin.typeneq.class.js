var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class ClassA {
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
	}
	class ClassB extends ClassA {
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			ClassA.prototype.__ks_cons.call(this, args);
		}
	}
	function foobar(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(!Type.isClassInstance(x, ClassB)) {
		}
		if(!Type.isClassInstance(x, ClassA) || !Type.isClassInstance(x, ClassB)) {
		}
	}
};