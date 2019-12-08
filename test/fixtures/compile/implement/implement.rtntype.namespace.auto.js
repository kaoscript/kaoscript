var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		return {};
	});
	NS.foobar = function() {
		return "foobar";
	};
	console.log(NS.foobar());
	return {
		NS: NS
	};
};