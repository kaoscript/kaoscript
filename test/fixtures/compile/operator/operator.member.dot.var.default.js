const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let b;
	let foo = Type.isValue((b = a.b).c);
};