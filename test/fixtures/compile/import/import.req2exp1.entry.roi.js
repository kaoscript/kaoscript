require("kaoscript/register");
const {Type} = require("@kaoscript/runtime");
module.exports = function(Foobar) {
	if(!Type.isValue(Foobar)) {
		var Foobar = require("./.import.req2exp1.pivot.ks.1b7cst1.ksb")().Foobar;
	}
	const f = Foobar.__ks_new_0();
	console.log(f.__ks_func_x_0());
};