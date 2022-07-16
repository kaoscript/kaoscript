const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = "bar";
	console.log(foo);
	foo = void 0;
	foo = 42;
	console.log(Helper.toString(foo));
};