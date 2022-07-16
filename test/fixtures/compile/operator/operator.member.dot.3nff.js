const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = Type.isValue(a) ? a.b.c : null;
};