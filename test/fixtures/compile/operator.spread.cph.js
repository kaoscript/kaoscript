var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let args = Helper.mapRange(1, 5, 1, true, true, (i) => {
		return i;
	});
	console.log.apply(console, args);
}