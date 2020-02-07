require("kaoscript/register");
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var foobar = require("../export/export.filter.func.native.noxp.ks")().foobar;
	console.log(Helper.toString(foobar("foobar").toSource()));
};