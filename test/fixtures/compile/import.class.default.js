require("kaoscript/register");
module.exports = function() {
	var Shape = require("./export.class.default.ks")().Shape;
	let shape = new Shape("red");
	console.log(shape._side);
}