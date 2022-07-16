const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const SpaceKind = Helper.enum(Number, {});
	return {
		SpaceKind
	};
};