const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const E = 2.71828;
	const PI = 3.14;
	const Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	return {
		Color
	};
};