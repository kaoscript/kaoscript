var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let m = "qux";
	let qux = Type.isValue(foo) ? foo[m]() : null;
};