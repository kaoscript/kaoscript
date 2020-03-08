var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(coord) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(coord === void 0 || coord === null) {
			throw new TypeError("'coord' is not nullable");
		}
		else if(!Type.isDictionary(coord) || !Type.isNumber(coord.x) || !Type.isNumber(coord.y)) {
			throw new TypeError("'coord' is not of type 'Coord'");
		}
	}
	return {
		foobar: foobar
	};
};