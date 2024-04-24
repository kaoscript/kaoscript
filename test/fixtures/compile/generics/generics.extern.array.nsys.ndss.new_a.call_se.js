const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const stack = new Stack();
	stack.push("hello", "world");
	let value, __ks_0;
	if((Type.isValue(__ks_0 = stack.pop()) ? (value = __ks_0, true) : false)) {
		console.log(Helper.toString(value));
	}
};