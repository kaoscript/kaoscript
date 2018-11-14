require("kaoscript/register");
module.exports = function() {
	var {console, Shape, __ks_Shape} = require("../export/export.sealed.class.nullable.ks")();
	let shape = new Shape("circle");
	console.log(__ks_Shape._im_draw(shape, "black"));
};