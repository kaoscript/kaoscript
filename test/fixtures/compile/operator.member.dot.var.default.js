var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let b;
	let foo = Type.isValue((b = a.b).c);
}