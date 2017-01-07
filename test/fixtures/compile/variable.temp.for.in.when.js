var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		let __ks_2;
		for(let __ks_0 = 0, __ks_1 = x.foo.length, value; __ks_0 < __ks_1; ++__ks_0) {
			value = x.foo[__ks_0];
			if(Type.isValue(__ks_2 = value.bar()) ? (value = __ks_2, true) : false) {
				console.log(value);
			}
		}
	}
}