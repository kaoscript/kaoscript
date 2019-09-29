var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		return {};
	});
	return {
		NS: NS
	};
};