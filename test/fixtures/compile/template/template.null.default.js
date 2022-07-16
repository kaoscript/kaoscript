const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const x = null;
	console.log(Helper.toString(x));
	console.log(Helper.toString(null));
};