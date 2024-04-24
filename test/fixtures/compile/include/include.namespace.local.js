const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let NS = Helper.namespace(function() {
		let x = 0;
		x += 42;
		return {};
	});
};