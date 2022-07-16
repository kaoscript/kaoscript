require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(template) {
	var __ks_Function = require("../_/._function.ks.j5k8r9.ksb")().__ks_Function;
	if(!Type.isValue(template)) {
		var template = require("./.import.systemic.function.source.ks.j5k8r9.ksb")().template;
	}
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function() {
		return 42;
	};
	foo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Function.__ks_func_toSource_0.call(foo));
	console.log(__ks_Function.__ks_func_toSource_0.call(template.__ks_func_compile_0()));
	return {
		template
	};
};