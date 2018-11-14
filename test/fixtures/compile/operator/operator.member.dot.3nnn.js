var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = (Type.isValue(a) && Type.isValue(a.b)) && Type.isValue(a.b.c);
};