var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = Type.isValue(foo.bar) ? foo.bar.qux : null;
};