const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let Foobar = Helper.namespace(function() {
		let x;
		x = "foobar";
		return {
			x
		};
	});
	return {
		Foobar
	};
};