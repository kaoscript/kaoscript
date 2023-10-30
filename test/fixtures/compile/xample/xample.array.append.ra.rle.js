require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("../_/._array.ks.j5k8r9.ksb")().__ks_Array;
	__ks_Array.__ks_func_appendAny_0 = function(args) {
		console.log(__ks_Array.__ks_func_last_0.call(args));
		for(let i = 0; i < args.length; ++i) {
			if(Type.isArray(args[i])) {
				console.log(__ks_Array.__ks_func_last_0.call(args[i]));
				this.push(...args[i]);
			}
			else {
				console.log(args[i]);
				this.push(args[i]);
			}
		}
		return this;
	};
	__ks_Array.__ks_func_appendArray_0 = function(args) {
		console.log(__ks_Array.__ks_func_last_0.call(args));
		for(let i = 0; i < args.length; ++i) {
			console.log(__ks_Array.__ks_func_last_0.call(args[i]));
			this.push(...args[i]);
		}
		return this;
	};
	__ks_Array._im_appendAny = function(that, ...args) {
		return __ks_Array.__ks_func_appendAny_rt(that, args);
	};
	__ks_Array.__ks_func_appendAny_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Array.__ks_func_appendAny_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	__ks_Array._im_appendArray = function(that, ...args) {
		return __ks_Array.__ks_func_appendArray_rt(that, args);
	};
	__ks_Array.__ks_func_appendArray_rt = function(that, args) {
		const t0 = Type.isArray;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Array.__ks_func_appendArray_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
};