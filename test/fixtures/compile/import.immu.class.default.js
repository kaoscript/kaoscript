require("kaoscript/register");
module.exports = function() {
	var {Color, Space} = require("./class.color.ks")();
	var {Color, Space} = require("./require.class.default.ks")(Color, Space);
	return {
		Color: Color,
		Space: Space
	};
};