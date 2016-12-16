var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let a = Helper.mapRange(0, 10, 1, true, true, (i) => {
		return i;
	});
}