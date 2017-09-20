var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = Type.isFunction(foo) ? foo(1, 2, 3) : undefined;
	let uu = Type.isFunction(foo) ? foo(1) : undefined;
};