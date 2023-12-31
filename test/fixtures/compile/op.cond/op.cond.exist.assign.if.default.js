const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = "otto";
	let bar;
	if(true && (Type.isValue(foo) ? (bar = foo, true) : false)) {
	}
};