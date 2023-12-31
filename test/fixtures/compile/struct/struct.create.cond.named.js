const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(a = null, b = null, c = null, d = null) {
		const _ = new OBJ();
		_.a = a;
		_.b = b;
		_.c = c;
		_.d = d;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 4) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t0, pts, 1) && Helper.isVarargs(args, 0, 1, t0, pts, 2) && Helper.isVarargs(args, 0, 1, t0, pts, 3) && te(pts, 4)) {
				return __ks_new(Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]));
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Foobar)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isNumber(arg = item.a) || Type.isNull(arg = item.a)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isNumber(arg = item.b) || Type.isNull(arg = item.b)) {
			return null;
		}
		args[1] = arg;
		if(!Type.isNumber(arg = item.c) || Type.isNull(arg = item.c)) {
			return null;
		}
		args[2] = arg;
		if(!Type.isNumber(arg = item.d) || Type.isNull(arg = item.d)) {
			return null;
		}
		args[3] = arg;
		return __ks_new.call(null, args);
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values, test) {
		values.push(Foobar.__ks_new(1, void 0, 3, (test() === true) ? 4 : void 0));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};