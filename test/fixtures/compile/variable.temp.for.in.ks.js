var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(Type.isValue(x.foo)) {
			for(let __ks_0 = 0, __ks_1 = x.foo.length, value; __ks_0 < __ks_1; ++__ks_0) {
				value = x.foo[__ks_0];
				console.log(value);
			}
		}
		if(Type.isValue(x.bar)) {
			for(let __ks_0 = 0, __ks_1 = x.bar.length, value; __ks_0 < __ks_1; ++__ks_0) {
				value = x.bar[__ks_0];
				console.log(value);
			}
		}
	}
}