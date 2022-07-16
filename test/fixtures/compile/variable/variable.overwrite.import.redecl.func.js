require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var name = require("../export/.export.default.ks.j5k8r9.ksb")().name;
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		let name = "foobar";
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};