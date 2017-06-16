require("kaoscript/register");
module.exports = function() {
	var {Color, Space} = require("./_color.default.ks")();
	var {Color, Space} = require("./_color.cie.ks")(Color, Space);
	console.log(Color, Space);
}