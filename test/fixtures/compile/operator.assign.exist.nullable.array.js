var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let bar;
	Type.isValue(foo) && Type.isValue(foo[qux]) ? bar = foo[qux] : undefined;
	console.log(foo, bar);
}