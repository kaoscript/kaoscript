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
		if(args.length > 1) {
			if(index !== 0) {
				if(index >= this.length) {
					for(let i = 0; i < args.length; ++i) {
						this.push.call(this, ...args[i]);
					}
				}
				else {
					for(let i = 0; i < args.length; ++i) {
						this.splice.call(this, index, 0, ...args[i]);
						index += [].concat(args[i]).length;
					}
				}
			}
			else {
				for(let i = args.length - 1; i >= 0; --i) {
					this.unshift.call(this, ...args[i]);
				}
			}
		}
		else {
			if(index !== 0) {
				if(index >= this.length) {
					this.push.call(this, ...args[0]);
				}
				else {
					this.splice.call(this, index, 0, ...args[0]);
				}
			}
			else {
				this.unshift.call(this, ...args[0]);
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