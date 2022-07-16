const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b) {
		return a;
	};
	foobar.__ks_1 = function(a, b, c, d) {
		if(c === void 0 || c === null) {
			c = false;
		}
		return b;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		const t2 = value => Type.isBoolean(value) || Type.isNull(value);
		const t3 = Type.isArray;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 3 && args.length <= 4) {
			if(t0(args[0]) && t1(args[1]) && Helper.isVarargs(args, 0, 1, t2, pts = [2], 0) && Helper.isVarargs(args, 1, 1, t3, pts, 1) && te(pts, 2)) {
				return foobar.__ks_1.call(that, args[0], args[1], Helper.getVararg(args, 2, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(a, b, c, d) {
		foobar.__ks_1(a, b, c, d);
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		const t2 = Type.isBoolean;
		const t3 = Type.isArray;
		if(args.length === 4) {
			if(t0(args[0]) && t1(args[1]) && t2(args[2]) && t3(args[3])) {
				return quxbaz.__ks_0.call(that, args[0], args[1], args[2], args[3]);
			}
		}
		throw Helper.badArgs();
	};
};