require("kaoscript/register");
module.exports = function() {
	var exec = require("./type.fusion.export.nrt.ks")().exec;
	const match = exec();
	console.log(match.input);
	console.log("" + match[0]);
	console.log(match[0]);
};