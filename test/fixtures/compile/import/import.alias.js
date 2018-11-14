require("kaoscript/register");
module.exports = function() {
	var foo = require("../export/export.default.ks")().name;
	console.log(foo);
};