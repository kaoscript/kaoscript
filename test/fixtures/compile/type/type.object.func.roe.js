var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_Object) {
	if(!Type.isValue(__ks_Object)) {
		__ks_Object = {};
	}
	class Foobar {
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
	function foobar() {
		if(arguments.length === 1 && Type.isClassInstance(arguments[0], Foobar)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isClassInstance(x, Foobar)) {
				throw new TypeError("'x' is not of type 'Foobar'");
			}
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isObject(x)) {
				throw new TypeError("'x' is not of type 'Object'");
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};