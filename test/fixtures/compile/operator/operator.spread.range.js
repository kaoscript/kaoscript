const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let args = Helper.newArrayRange(1, 2, 1, true, true);
	console.log(...args);
};