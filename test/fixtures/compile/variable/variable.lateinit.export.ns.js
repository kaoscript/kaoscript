var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Foobar = Helper.namespace(function() {
		let x = null;
		x = "foobar";
		return {
			x: x
		};
	});
	return {
		Foobar: Foobar
	};
};