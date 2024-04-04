require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var {console, __ks_Number, Math, __ks_Math} = require("../export/.export.sealed.namespace.impl.default.ks.j5k8r9.ksb")();
	console.log(Helper.toString(Math.PI));
	console.log(Helper.toString(__ks_Math.pi));
	console.log(Helper.toString(__ks_Math.foo.__ks_0()));
	console.log(Helper.toString(Math.PI.toString()));
	console.log(Helper.toString(__ks_Math.pi.toString()));
	console.log(Helper.toString(__ks_Math.foo.__ks_0().toString()));
};