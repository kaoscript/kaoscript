var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(Type.isValue(x.foo)) {
			let __ks_0 = x.foo;
			for(let key in __ks_0) {
				let value = __ks_0[key];
				console.log(key, value);
			}
		}
		if(Type.isValue(x.bar)) {
			let __ks_0 = x.bar;
			for(let key in __ks_0) {
				let value = __ks_0[key];
				console.log(key, value);
			}
		}
	}
}