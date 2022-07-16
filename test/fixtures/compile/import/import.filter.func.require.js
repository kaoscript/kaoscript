require("kaoscript/register");
module.exports = function() {
	var Foobar = require("../export/.export.but.all.ks.j5k8r9.ksb")().Foobar;
	var foobar = require("../export/.export.filter.func.require.ks.tdkon1.ksb")(Foobar).foobar;
	console.log(foobar.__ks_0("foobar"));
	const x = Foobar.__ks_new_0();
	console.log(foobar.__ks_1(x).__ks_func_toString_0());
	return {
		Foobar,
		foobar
	};
};