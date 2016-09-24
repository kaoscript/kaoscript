var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = Type.isValue(a) ? a.b.c : undefined;
}