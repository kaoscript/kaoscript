require("kaoscript/register");
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var exec = require("./type.fusion.export.wrt.ks")().exec;
	const match = exec();
	console.log(match.input);
	console.log(Helper.toString(match[0]));
	console.log(match[0]);
};