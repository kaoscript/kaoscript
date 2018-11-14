require("kaoscript/register");
module.exports = function() {
	var name = require("../export/export.default.ks")().name;
	console.log(name);
};