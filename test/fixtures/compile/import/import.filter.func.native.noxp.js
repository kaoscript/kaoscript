require("kaoscript/register");
module.exports = function() {
	var foobar = require("../export/export.filter.func.native.noxp.ks")().foobar;
	console.log("" + foobar("foobar").toSource());
};