require("kaoscript/register");
module.exports = function() {
	var {Color: C, Space: S} = require("./_color.default.ks")();
	console.log(C, S);
	var {Color: C, Space: S} = require("./_color.cie.ks")(C, S);
	console.log(C, S);
}