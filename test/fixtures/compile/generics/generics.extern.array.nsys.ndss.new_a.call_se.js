const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const stack = new Stack();
	stack.push("hello", "world");
	let value = stack.pop();
	if(Type.isValue(value)) {
		console.log(Helper.toString(value));
	}
};