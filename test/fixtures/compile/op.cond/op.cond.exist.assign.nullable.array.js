const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let bar;
	Type.isValue(foo) && Type.isValue(foo[qux]) ? bar = foo[qux] : null;
	console.log(foo, bar);
};