const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_Array, __ks_String) {
	if(!__ks_Array) {
		__ks_Array = {};
	}
	if(!__ks_String) {
		__ks_String = {};
	}
	__ks_Array.__ks_func_last_0 = function(index) {
		if(index === void 0 || index === null) {
			index = 1;
		}
		return (this.length !== 0) ? this[this.length - index] : null;
	};
	__ks_Array._im_last = function(that, ...args) {
		return __ks_Array.__ks_func_last_rt(that, args);
	};
	__ks_Array.__ks_func_last_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_Array.__ks_func_last_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	__ks_String.__ks_func_lines_0 = function(emptyLines) {
		if(emptyLines === void 0 || emptyLines === null) {
			emptyLines = false;
		}
		if(this.length === 0) {
			return [];
		}
		else if(emptyLines) {
			return this.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n");
		}
		else {
			let __ks_0;
			return Type.isValue(__ks_0 = this.match(/[^\r\n]+/g)) ? __ks_0 : [];
		}
	};
	__ks_String._im_lines = function(that, ...args) {
		return __ks_String.__ks_func_lines_rt(that, args);
	};
	__ks_String.__ks_func_lines_rt = function(that, args) {
		const t0 = value => Type.isBoolean(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_String.__ks_func_lines_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	return {
		__ks_Array,
		__ks_String
	};
};