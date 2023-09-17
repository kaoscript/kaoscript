require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Boolean = require("../_/._boolean.ks.j5k8r9.ksb")().__ks_Boolean;
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	function test() {
		return test.__ks_rt(this, arguments);
	};
	test.__ks_0 = function(x) {
		return true;
	};
	test.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return test.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		let x = false;
		let y = false;
		if(test.__ks_0(x = "1") && test.__ks_0(y = "2")) {
			console.log(__ks_String.__ks_func_toInt_0.call(x));
			console.log(__ks_String.__ks_func_toInt_0.call(y));
		}
		else {
			console.log(__ks_String.__ks_func_toInt_0.call(x));
			console.log(Type.isBoolean(y) ? __ks_Boolean.__ks_func_toInt_0.call(y) : __ks_String.__ks_func_toInt_0.call(y));
		}
		console.log(__ks_String.__ks_func_toInt_0.call(x));
		console.log(Type.isString(y) ? __ks_String.__ks_func_toInt_0.call(y) : __ks_Boolean.__ks_func_toInt_0.call(y));
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};