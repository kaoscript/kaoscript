const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const FontWeight = Helper.enum(Number, {
		Bold: 0,
		Normal: 1
	});
	const fontWeight = FontWeight.Normal;
};