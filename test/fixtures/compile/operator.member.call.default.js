var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = Type.isFunction(foo) ? foo() : undefined;
}