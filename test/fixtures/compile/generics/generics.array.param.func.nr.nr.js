var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(functions) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(functions === void 0 || functions === null) {
			throw new TypeError("'functions' is not nullable");
		}
		else if(!Type.isArray(functions)) {
			throw new TypeError("'functions' is not of type 'Array<(x: String)>'");
		}
		for(let __ks_0 = 0, __ks_1 = functions.length, fn; __ks_0 < __ks_1; ++__ks_0) {
			fn = functions[__ks_0];
			fn("foobar");
		}
	}
};