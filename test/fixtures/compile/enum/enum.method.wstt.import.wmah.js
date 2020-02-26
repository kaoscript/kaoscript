require("kaoscript/register");
module.exports = function() {
	var Weekday = require("./enum.method.wstt.default.ks")().Weekday;
	const day = Weekday.fromString("monday");
	return {
		Weekday: Weekday
	};
};