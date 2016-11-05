var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
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
}