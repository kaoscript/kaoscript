require("kaoscript/register");
module.exports = function() {
	var {y, z} = require("@kaoscript/test-import/src/export.ks")();
	console.log(x, y, z);
};