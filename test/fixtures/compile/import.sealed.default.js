require("kaoscript/register");
module.exports = function() {
	var {console, Shape, __ks_Shape} = require("./export.sealed.class.default.ks")();
	let shape = new Shape("yellow");
	console.log(__ks_Shape._im_draw(shape, "rectangle"));
}