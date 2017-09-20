require("kaoscript/register");
module.exports = function() {
	var Float = require("./namespace.export.default.ks")().Float;
	console.log(Float.toString(3.14));
};