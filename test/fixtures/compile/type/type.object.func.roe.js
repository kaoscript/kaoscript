var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(Object, typeof __ks_Object === "undefined" ? {} : __ks_Object);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [Object, __ks_Object] = __ks_require(__ks_0, __ks___ks_0);
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
		if(arguments.length === 1 && Type.isInstance(arguments[0], Foobar)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isInstance(x, Foobar)) {
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