require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(Foobar, __ks_Foobar) {
	if(!Type.isValue(Foobar)) {
		var {Foobar, __ks_Foobar} = require("./require.tangled.augment.ks")();
	}
	return {
		Foobar: Foobar,
		__ks_Foobar: __ks_Foobar
	};
};