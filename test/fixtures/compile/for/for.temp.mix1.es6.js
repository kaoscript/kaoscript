var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
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
};