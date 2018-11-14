var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = "otto";
	let bar;
	if(true && (Type.isValue(foo) ? (bar = foo, true) : false)) {
	}
};