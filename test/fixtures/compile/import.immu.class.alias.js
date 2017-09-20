require("kaoscript/register");
module.exports = function() {
	var {Color: C, Space: S} = require("./class.color.ks")();
	var {Color: C, Space: S} = require("./require.class.default.ks")(C, S);
	return {
		Color: C,
		Space: S
	};
};