var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x, y, z) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(y === undefined || y === null) {
			throw new Error("Missing parameter 'y'");
		}
		if(z === undefined || z === null) {
			throw new Error("Missing parameter 'z'");
		}
		for(let __ks_0 = 0, __ks_1 = y.length, value; __ks_0 < __ks_1; ++__ks_0) {
			value = y[__ks_0];
			console.log(value);
		}
		for(let __ks_0 = 0, __ks_1 = z.length, value; __ks_0 < __ks_1; ++__ks_0) {
			value = z[__ks_0];
			console.log(value);
		}
		if(Type.isValue(x.bar)) {
			for(let key in x.bar) {
				let value = x.bar[key];
				console.log(key, value);
			}
			for(let key in x.bar) {
				let value = x.bar[key];
				console.log(key, value);
			}
		}
	}
}