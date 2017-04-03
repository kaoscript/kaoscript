require("kaoscript/register");
module.exports = function() {
	var T = require("./export.sealed.class.ks")();
	let shape = new T.Shape("yellow");
	T.console.log(T.__ks_Shape._im_draw(shape, "rectangle"));
}