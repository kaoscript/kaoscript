const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let min = 1;
	let max = 5;
	let a = Helper.newArrayRange(min, max, 1, true, true);
};