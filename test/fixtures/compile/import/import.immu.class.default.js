require("kaoscript/register");
module.exports = function() {
	var {Color, Space} = require("../class/class.color.ks")();
	var {Color, Space} = require("../require/require.class.default.ks")(Color, Space);
	return {
		Color: Color,
		Space: Space
	};
};