require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {__ks_Array, __ks_String} = require("./.extern.disclose.string.array.default.ks.j5k8r9.ksb")();
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(value) {
		console.log(value.trim());
		const list = value.split(",");
		console.log(list[0]);
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};