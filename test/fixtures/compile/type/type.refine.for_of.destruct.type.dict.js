var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(values) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(values === void 0 || values === null) {
			throw new TypeError("'values' is not nullable");
		}
		else if(!Type.isDictionary(values)) {
			throw new TypeError("'values' is not of type 'Dictionary<Coord>'");
		}
		let r = 0;
		for(let __ks_0 in values) {
			const {x, y, z} = values[__ks_0];
			r += Number.parseInt((x * y) / z);
		}
		return r;
	}
};