var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		if(Type.isValue(x.foo)) {
			for(let key in x.foo) {
				let value = x.foo[key];
				console.log(key, value);
			}
		}
		if(Type.isValue(x.bar)) {
			for(let key in x.bar) {
				let value = x.bar[key];
				console.log(key, value);
			}
		}
	}
}