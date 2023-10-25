const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(items) {
		console.log(items);
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return foo.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function(x, items) {
		console.log(x, items);
	};
	bar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 1, t0, pts = [1], 0) && te(pts, 1)) {
				return bar.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function baz() {
		return baz.__ks_rt(this, arguments);
	};
	baz.__ks_0 = function(x, items, z) {
		console.log(x, items, z);
	};
	baz.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 2) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [1], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
				return baz.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
	function qux() {
		return qux.__ks_rt(this, arguments);
	};
	qux.__ks_0 = function(x, items, z) {
		if(z === void 0 || z === null) {
			z = 1;
		}
		console.log(x, items, z);
	};
	qux.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, args.length - 2, t0, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
				return qux.__ks_0.call(that, args[0], Helper.getVarargs(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
	function quux() {
		return quux.__ks_rt(this, arguments);
	};
	quux.__ks_0 = function(x, items, z) {
		if(x === void 0 || x === null) {
			x = 1;
		}
		if(z === void 0 || z === null) {
			z = 1;
		}
		console.log(x, items, z);
	};
	quux.__ks_rt = function(that, args) {
		const t0 = Type.any;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, args.length - 2, t1, pts, 1) && Helper.isVarargs(args, 0, 1, t0, pts, 2) && te(pts, 3)) {
			return quux.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]), Helper.getVarargs(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
		}
		throw Helper.badArgs();
	};
	function corge() {
		return corge.__ks_rt(this, arguments);
	};
	corge.__ks_0 = function(items) {
		if(items.length === 0) {
			items = Helper.newArrayRange(1, 5, 1, true, true);
		}
		console.log(items);
	};
	corge.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return corge.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	function grault() {
		return grault.__ks_rt(this, arguments);
	};
	grault.__ks_0 = function(items, z) {
		console.log(items, z);
	};
	grault.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1) {
			if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && te(pts, 2)) {
				return grault.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	};
	function garply() {
		return garply.__ks_rt(this, arguments);
	};
	garply.__ks_0 = function(items, z) {
		if(z === void 0 || z === null) {
			z = 1;
		}
		console.log(items, z);
	};
	garply.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 0, 1, t1, pts, 1) && te(pts, 2)) {
			return garply.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
		}
		throw Helper.badArgs();
	};
	function waldo() {
		return waldo.__ks_rt(this, arguments);
	};
	waldo.__ks_0 = function(items, x, y, z) {
		console.log(items, x, y, z);
	};
	waldo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 3) {
			if(Helper.isVarargs(args, 0, args.length - 3, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && Helper.isVarargs(args, 1, 1, t0, pts, 2) && Helper.isVarargs(args, 1, 1, t0, pts, 3) && te(pts, 4)) {
				return waldo.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]));
			}
		}
		throw Helper.badArgs();
	};
	function fred() {
		return fred.__ks_rt(this, arguments);
	};
	fred.__ks_0 = function(items, x, y, z) {
		if(y === void 0 || y === null) {
			y = 1;
		}
		console.log(items, x, y, z);
	};
	fred.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.any;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fred.__ks_0.call(that, [], args[0], void 0, args[1]);
			}
			throw Helper.badArgs();
		}
		if(args.length >= 3) {
			if(Helper.isVarargs(args, 0, args.length - 3, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t0, pts, 1) && Helper.isVarargs(args, 1, 1, t1, pts, 2) && Helper.isVarargs(args, 1, 1, t0, pts, 3) && te(pts, 4)) {
				return fred.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]), Helper.getVararg(args, pts[3], pts[4]));
			}
		}
		throw Helper.badArgs();
	};
};