require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("../_/._array.ks.j5k8r9.ksb")().__ks_Array;
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		if(Type.isArray(x)) {
			console.log(__ks_Array.__ks_func_last_0.call(x));
			if(qux(x = __ks_Array.__ks_func_last_0.call(x)) === true) {
				console.log(x.last());
			}
			else {
				console.log(x.last());
			}
		}
		else {
			console.log(x.last());
		}
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};