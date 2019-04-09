var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		for(let key in x.foo) {
			let value = x.foo[key];
			let __ks_0;
			if(!(Type.isValue(__ks_0 = value.bar()) ? (value = __ks_0, true) : false)) {
				break;
			}
			console.log(key, value);
		}
	}
};