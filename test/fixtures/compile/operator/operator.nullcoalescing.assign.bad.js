var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = foo();
	Type.isValue(tt) ? tt : (tt = bar());
};