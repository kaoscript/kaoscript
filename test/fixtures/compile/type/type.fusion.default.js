const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const match = exec();
	console.log(match.input);
	console.log(Helper.toString(match[0]));
	console.log(match[0]);
};