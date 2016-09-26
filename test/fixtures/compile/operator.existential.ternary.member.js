var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = Type.isValue(foo.bar) ? "bar" : "qux";
}