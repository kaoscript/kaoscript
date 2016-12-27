module.exports = function() {
	var {Shape, __ks_Shape} = require("./export.sealed.class.ks")();
	let shape = new Shape("yellow");
	console.log(__ks_Shape._im_draw(shape, "rectangle"));
}