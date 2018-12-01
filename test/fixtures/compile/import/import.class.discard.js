require("kaoscript/register");
module.exports = function() {
	var Shape = require("../export/export.class.discard.ks")().Shape;
	let shape = new Shape("rectangle");
	console.log(shape.name());
	console.log(shape.color());
};