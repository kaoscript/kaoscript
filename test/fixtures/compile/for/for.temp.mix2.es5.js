var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(Type.isValue(x.foo)) {
			for(var __ks_0 = 0, __ks_1 = x.foo.length, value; __ks_0 < __ks_1; ++__ks_0) {
				value = x.foo[__ks_0];
				var __ks_2 = value.kind;
				if(__ks_2 === 42) {
					for(var __ks_3 = 0, __ks_4 = value.values.length, v; __ks_3 < __ks_4; ++__ks_3) {
						v = value.values[__ks_3];
						console.log(value);
					}
				}
			}
		}
	}
};