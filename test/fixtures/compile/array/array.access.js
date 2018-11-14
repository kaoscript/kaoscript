var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let n = Helper.newArrayRange(1, 3, 1, true, true);
	console.log(n[0]);
};