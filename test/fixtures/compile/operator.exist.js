var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = Type.isValue(x) ? x : y;
	let bar = Type.vexists(x(), y);
	let qux = Type.vexists(x, y, z);
}