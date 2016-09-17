module.exports = function() {
	var foo = require("./export.default.ks")().name;
	console.log(foo);
}