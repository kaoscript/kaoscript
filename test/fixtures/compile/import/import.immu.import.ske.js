const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const SpaceKind = Helper.enum(Number, 0);
	return {
		SpaceKind
	};
};