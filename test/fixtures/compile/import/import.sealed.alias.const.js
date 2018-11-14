require("kaoscript/register");
module.exports = function() {
	var T = require("../export/export.sealed.class.default.ks")();
	const shape = new T.Shape("yellow");
	T.console.log(T.__ks_Shape._im_draw(shape, "rectangle"));
};