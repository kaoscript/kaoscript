var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foobar {
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
	function foobar() {
		if(arguments.length === 1) {
			if(Type.isString(arguments[0])) {
				let __ks_i = -1;
				let x = arguments[++__ks_i];
				if(x === void 0 || x === null) {
					throw new TypeError("'x' is not nullable");
				}
				else if(!Type.isString(x)) {
					throw new TypeError("'x' is not of type 'String'");
				}
			}
			else {
				let __ks_i = -1;
				let x = arguments[++__ks_i];
				if(x === void 0 || x === null) {
					throw new TypeError("'x' is not nullable");
				}
				else if(!Type.is(x, Foobar)) {
					throw new TypeError("'x' is not of type 'Foobar'");
				}
			}
		}
		else {
			throw new SyntaxError("wrong number of arguments");
		}
	};
	return {
		foobar: foobar
	};
};