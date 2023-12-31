const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = "otto";
	let bar;
	Type.isValue(foo) ? bar = foo : null;
	console.log(foo, bar);
};