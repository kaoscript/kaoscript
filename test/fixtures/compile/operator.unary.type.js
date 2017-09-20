var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let x = "john";
	console.log("" + Type.isValue(x.toUpperCase));
};