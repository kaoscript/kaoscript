const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let args = Helper.mapRange(1, 5, 1, true, true, function(i) {
		return i;
	});
	console.log(...args);
};