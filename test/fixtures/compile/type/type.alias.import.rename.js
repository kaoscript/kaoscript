require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Number = require("../_/._number.ks.j5k8r9.ksb")().__ks_Number;
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	var NS = require("./.type.alias.export.decl.ks.j5k8r9.ksb")().T;
	let n = 0;
	console.log(__ks_Number.__ks_func_toInt_0.call(n));
	let s = "";
	console.log(__ks_String.__ks_func_toInt_0.call(s));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		console.log(Type.isNumber(x) ? __ks_Number.__ks_func_toInt_0.call(x) : __ks_String.__ks_func_toInt_0.call(x));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isString(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	n = "";
	console.log(__ks_String.__ks_func_toInt_0.call(n));
	n = 42;
	console.log(__ks_Number.__ks_func_toInt_0.call(n));
	function qux() {
		return qux.__ks_rt(this, arguments);
	};
	qux.__ks_0 = function() {
		return 42;
	};
	qux.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return qux.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	n = qux.__ks_0();
	console.log(Type.isNumber(n) ? __ks_Number.__ks_func_toInt_0.call(n) : __ks_String.__ks_func_toInt_0.call(n));
};