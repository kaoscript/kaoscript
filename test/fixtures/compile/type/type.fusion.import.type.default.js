require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Result = require("./.type.fusion.export.type.ks.j5k8r9.ksb")().Result;
	function process() {
		return process.__ks_rt(this, arguments);
	};
	process.__ks_0 = function(result) {
		return "hello";
	};
	process.__ks_rt = function(that, args) {
		const t0 = Result.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return process.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	return {
		process
	};
};