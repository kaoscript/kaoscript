var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let tt = (foo === true) || ((bar === true) && (Type.isValue(qux) ? qux.qux === true : false));
};