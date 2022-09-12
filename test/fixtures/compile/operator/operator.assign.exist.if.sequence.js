const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = "otto";
	let quz = 0;
	let bar;
	if((quz += 1, true) && (quz += 1, Type.isValue(foo) ? (bar = foo, true) : false)) {
	}
};