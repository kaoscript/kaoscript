require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var {exec, __ksType: __ksType0} = require("./.type.fusion.export.func.wrt.ks.j5k8r9.ksb")();
	const match = exec();
	console.log(match.input);
	console.log(Helper.toString(match[0]));
	console.log(match[0]);
};