require("kaoscript/register");
module.exports = function() {
	var {x, y, z} = require("@kaoscript/test-import/src/export")();
	console.log(x, y, z);
};