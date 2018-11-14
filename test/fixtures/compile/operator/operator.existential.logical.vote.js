var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = foo.foo || (Type.isValue(bar) ? bar.bar : false);
};