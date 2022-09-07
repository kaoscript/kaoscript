require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(Template, template) {
	var __ks_Function = require("../_/._function.ks.j5k8r9.ksb")().__ks_Function;
	var __ks_0_valuable = Type.isValue(Template);
	var __ks_1_valuable = Type.isValue(template);
	if(!__ks_0_valuable || !__ks_1_valuable) {
		var __ks__ = require("./.import.system.function.source.ks.j5k8r9.ksb")();
		if(!__ks_0_valuable) {
			Template = __ks__.Template;
		}
		if(!__ks_1_valuable) {
			template = __ks__.template;
		}
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
};