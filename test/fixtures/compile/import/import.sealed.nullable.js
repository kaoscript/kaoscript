require("kaoscript/register");
module.exports = function() {
	var {console, Shape, __ks_Shape} = require("../export/.export.sealed.class.nullable.ks.j5k8r9.ksb")();
	const shape = Shape.__ks_new_0("circle");
	console.log(__ks_Shape.__ks_func_draw_0.call(shape, "black"));
};