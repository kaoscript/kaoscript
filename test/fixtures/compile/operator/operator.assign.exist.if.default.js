const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = "otto";
	let bar = null;
	if(true && (Type.isValue(foo) ? (bar = foo, true) : false)) {
	}
};