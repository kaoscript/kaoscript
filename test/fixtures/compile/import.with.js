module.exports = function() {
	var {Color, Space} = require("./_color.ks")();
	var {Color, Space} = require("./_color.cie.ks")(Color, Space);
	console.log(Color, Space);
}