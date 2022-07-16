require("kaoscript/register");
module.exports = function() {
	var T = require("../export/.export.sealed.class.default.ks.j5k8r9.ksb")();
	var {Shape, __ks_Shape} = T;
	const shape = Shape.__ks_new_0("yellow");
	T.console.log(__ks_Shape.__ks_func_draw_0.call(shape, "rectangle"));
	const shapeT = T.Shape.__ks_new_0("yellow");
	T.console.log(T.__ks_Shape.__ks_func_draw_0.call(shapeT, "rectangle"));
};