var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let NS = Helper.namespace(function() {
		const E = 2.71828;
		const PI = 3.14;
		let Color = Helper.enum(Number, {
			Red: 0,
			Green: 1,
			Blue: 2
		});
		return {};
	});
};