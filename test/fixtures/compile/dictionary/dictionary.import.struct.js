require("kaoscript/register");
module.exports = function() {
	var Coord = require("./dictionary.anonym.struct.ks")().Coord;
	return {
		Coord: Coord
	};
};