require("kaoscript/register");
module.exports = function() {
	var toInt = require("./type.alias.export.ref.ks")().toInt;
	console.log(toInt(3.14));
	console.log(toInt(42));
};