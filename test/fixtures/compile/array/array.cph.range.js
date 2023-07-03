const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const a = Helper.mapRange(0, 10, 1, true, true, function(i) {
		return i;
	});
};