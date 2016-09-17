var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = "otto";
	let bar;
	Type.isValue(foo) ? bar = foo : undefined;
	console.log(foo, bar);
}