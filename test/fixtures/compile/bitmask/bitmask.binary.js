const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Days = Helper.enum(Number, {
		None: 0,
		Monday: 1,
		Tuesday: 2,
		Wednesday: 4,
		Thursday: 8,
		Friday: 16,
		Saturday: 32,
		Sunday: 64,
		Weekend: 96
	});
};