require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var {exec, RegExpExecArray} = require("./.type.fusion.export.func.wrt.ks.j5k8r9.ksb")();
	const match = exec();
	console.log(match.input);
	console.log(Helper.toString(match[0]));
	console.log(match[0]);
};