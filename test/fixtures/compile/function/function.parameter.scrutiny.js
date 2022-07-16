const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		console.log(x);
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function(x) {
		if(x === void 0) {
			x = null;
		}
		console.log(x);
	};
	bar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return bar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	function baz() {
		return baz.__ks_rt(this, arguments);
	};
	baz.__ks_0 = function(x = null) {
		console.log(x);
	};
	baz.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return baz.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	function qux() {
		return qux.__ks_rt(this, arguments);
	};
	qux.__ks_0 = function(x) {
		if(x === void 0 || x === null) {
			x = "foobar";
		}
		console.log(x);
	};
	qux.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return qux.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	function quux() {
		return quux.__ks_rt(this, arguments);
	};
	quux.__ks_0 = function(x) {
		console.log(x);
	};
	quux.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return quux.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function corge() {
		return corge.__ks_rt(this, arguments);
	};
	corge.__ks_0 = function(x) {
		if(x === void 0) {
			x = null;
		}
		console.log(x);
	};
	corge.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return corge.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function grault() {
		return grault.__ks_rt(this, arguments);
	};
	grault.__ks_0 = function(x = null) {
		console.log(x);
	};
	grault.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return grault.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function garply() {
		return garply.__ks_rt(this, arguments);
	};
	garply.__ks_0 = function(x) {
		if(x === void 0 || x === null) {
			x = "foobar";
		}
		console.log(x);
	};
	garply.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return garply.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function waldo() {
		return waldo.__ks_rt(this, arguments);
	};
	waldo.__ks_0 = function(x = null) {
		console.log(x);
	};
	waldo.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return waldo.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function fred() {
		return fred.__ks_rt(this, arguments);
	};
	fred.__ks_0 = function(x = "foobar") {
		console.log(x);
	};
	fred.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return fred.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};