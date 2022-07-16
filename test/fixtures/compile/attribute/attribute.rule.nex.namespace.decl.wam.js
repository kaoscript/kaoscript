const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		return {};
	});
	NS.foobar();
};