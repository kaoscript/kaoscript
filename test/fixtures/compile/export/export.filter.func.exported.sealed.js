var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Foobar = {};
	__ks_Foobar.__ks_func_foo_0 = function() {
	};
	__ks_Foobar._im_foo = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Foobar.__ks_func_foo_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	function foobar() {
		return new Foobar();
	}
	function qux() {
		if(arguments.length === 1 && Type.isString(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			return x;
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.is(x, Foobar)) {
				throw new TypeError("'x' is not of type 'Foobar'");
			}
			return x;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	return {
		foobar: foobar,
		qux: qux
	};
};