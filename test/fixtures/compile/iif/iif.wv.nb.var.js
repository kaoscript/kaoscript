const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let y = foo();
	const x = Type.isValue(y) ? qux(y) : bar();
};