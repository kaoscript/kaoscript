var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(Type.isValue(x.foo)) {
			for(var __ks_0 = 0, __ks_1 = x.foo.length, value; __ks_0 < __ks_1; ++__ks_0) {
				value = x.foo[__ks_0];
				console.log(value);
			}
		}
		if(Type.isValue(x.bar)) {
			for(var __ks_0 = 0, __ks_1 = x.bar.length, value; __ks_0 < __ks_1; ++__ks_0) {
				value = x.bar[__ks_0];
				console.log(value);
			}
		}
	}
}