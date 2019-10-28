var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function equals(itemA, itemB) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(itemA === void 0 || itemA === null) {
			throw new TypeError("'itemA' is not nullable");
		}
		else if(!Type.isObject(itemA)) {
			throw new TypeError("'itemA' is not of type 'Object'");
		}
		if(itemB === void 0 || itemB === null) {
			throw new TypeError("'itemB' is not nullable");
		}
		else if(!Type.isObject(itemB)) {
			throw new TypeError("'itemB' is not of type 'Object'");
		}
		return Object.equals(itemA, itemB);
	}
};