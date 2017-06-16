require("kaoscript/register");
module.exports = function() {
	var __ks_0 = require("./export.sealed.class.default.ks")();
	var {Shape, __ks_Shape} = __ks_0;
	var T = __ks_0;
	const shape = new Shape("yellow");
	T.console.log(__ks_Shape._im_draw(shape, "rectangle"));
	const shapeT = new T.Shape("yellow");
}