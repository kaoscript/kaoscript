var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = Type.isValue(foo) ? foo : bar(12, 42);
}