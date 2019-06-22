require("kaoscript/register");
module.exports = function() {
	var T = require("../export/export.sealed.class.default.ks")();
	var {Shape, __ks_Shape} = T;
	const shape = new Shape("yellow");
	T.console.log(__ks_Shape._im_draw(shape, "rectangle"));
	const shapeT = new T.Shape("yellow");
	T.console.log(T.__ks_Shape._im_draw(shapeT, "rectangle"));
};