var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Master {
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
		if(arguments.length === 1 && Type.isClassInstance(arguments[0], Master)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isClassInstance(x, Master)) {
				throw new TypeError("'x' is not of type 'Master'");
			}
			return 2;
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x) && !Type.isString(x)) {
				throw new TypeError("'x' is not of type 'Number' or 'String'");
			}
			return 1;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};