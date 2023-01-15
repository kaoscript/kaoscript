const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const values = Helper.mapRange(0, 10, 1, true, true, function() {
		return "Hello world!";
	});
};