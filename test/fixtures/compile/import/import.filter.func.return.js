require("kaoscript/register");
module.exports = function() {
	var foobar = require("../export/export.filter.func.return.ks")().foobar;
	console.log(foobar("").toString());
};