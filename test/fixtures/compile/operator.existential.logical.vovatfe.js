var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = foo || (bar && (Type.isValue(qux) ? qux.qux() : false));
};