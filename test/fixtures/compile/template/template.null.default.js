var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	const x = null;
	console.log(Helper.toString(x));
	console.log(Helper.toString(null));
};