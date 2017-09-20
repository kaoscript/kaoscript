require("kaoscript/register");
module.exports = function() {
	var name = require("./export.default.ks")().name;
	console.log(name);
};