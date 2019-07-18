var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_Foobar = {};
	__ks_Foobar.__ks_func_foobar_0 = function() {
	};
	__ks_Foobar._im_foobar = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_Foobar.__ks_func_foobar_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isBoolean(x)) {
			throw new TypeError("'x' is not of type 'Boolean'");
		}
		let y = null;
		y = bar();
		if(y !== null) {
			__ks_Foobar._im_foobar(y);
		}
	}
	function bar() {
	}
};