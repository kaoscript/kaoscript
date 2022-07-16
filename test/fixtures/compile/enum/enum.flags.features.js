const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.enum(Object, {
		NoFeatures: 0n,
		Feature1: 1n,
		Feature2: 2n,
		Feature3: 4n,
		Feature4: 8n,
		Feature32: 2147483648n,
		Feature53: 4503599627370496n
	});
};