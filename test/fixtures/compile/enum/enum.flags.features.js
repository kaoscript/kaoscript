var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Foobar = Helper.enum(Number, {
		NoFeatures: 0,
		Feature1: 1,
		Feature2: 2,
		Feature3: 4,
		Feature4: 8,
		Feature32: 2147483648,
		Feature53: 4503599627370496
	});
};