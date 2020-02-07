var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	const match = exec();
	console.log(match.input);
	console.log(Helper.toString(match[0]));
	console.log(match[0]);
};