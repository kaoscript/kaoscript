require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = require("../_/._array.ks.j5k8r9.ksb")().__ks_Array;
	__ks_Array.__ks_func_injectAt_0 = function(index, args) {
		if(index < 0) {
			do {
				index = this.length + index + 1;
			}
			while(index < 0)
		}
		if(index !== 0) {
			if(index >= this.length) {
				for(let i = 0; i < args.length; ++i) {
					if(Type.isArray(args[i])) {
						this.push(...args[i]);
					}
					else {
						this.push(args[i]);
					}
				}
			}
			else {
				for(let i = 0; i < args.length; ++i) {
					if(Type.isArray(args[i])) {
						this.splice(index, 0, ...args[i]);
						index += args[i].length;
					}
					else {
						this.splice(index, 0, args[i]);
						index += 1;
					}
				}
			}
		}
		else {
			for(let i = args.length - 1; i >= 0; --i) {
				if(Type.isArray(args[i])) {
					this.unshift(...args[i]);
				}
				else {
					this.unshift(args[i]);
				}
			}
		}
		return this;
	};
	__ks_Array._im_injectAt = function(that, ...args) {
		return __ks_Array.__ks_func_injectAt_rt(that, args);
	};
	__ks_Array.__ks_func_injectAt_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t1, pts = [1], 0) && te(pts, 1)) {
				return __ks_Array.__ks_func_injectAt_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};