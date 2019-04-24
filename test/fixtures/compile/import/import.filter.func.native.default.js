require("kaoscript/register");
module.exports = function() {
	var {foobar, Function, __ks_Function} = require("../export/export.filter.func.native.default.ks")();
	console.log(__ks_Function._im_toSource(foobar("foobar")));
};