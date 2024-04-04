require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("../_/._array.ks.j5k8r9.ksb")().__ks_Array;
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x, values) {
		if(Type.isArray(x)) {
			console.log(__ks_Array.__ks_func_last_0.call(x));
			if(values[x = Helper.assert(__ks_Array.__ks_func_last_0.call(x), "\"Any\"", 0, Type.isValue)] === true) {
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
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foo.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};