const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let x = 1;
	let y = 3;
	console.log(x + y);
	console.log(Helper.concatString("foo", x, y, "bar"));
	console.log(Helper.concatString("foo", (x + y), "bar"));
};