require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Shape = require("./.implement.static.gss.ks.j5k8r9.ksb")().Shape;
	Shape.__ks_sttc_makeRed_0 = function() {
		return Shape.__ks_new_0("red");
	};
	Shape.makeRed = function() {
		if(arguments.length === 0) {
			return Shape.__ks_func_makeRed_0();
		}
		throw Helper.badArgs();
	};
	let shape = Shape.__ks_sttc_makeRed_0();
	console.log(shape.__ks_func_draw_0());
};