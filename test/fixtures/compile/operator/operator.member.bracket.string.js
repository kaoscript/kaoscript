var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let qux = Type.isValue(foo) ? foo["qux"] : undefined;
};