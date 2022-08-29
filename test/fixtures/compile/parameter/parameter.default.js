const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(item) {
		if(item === void 0 || item === null) {
			item = 1;
		}
		console.log(item);
	};
	foo.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return foo.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function(item) {
		if(item === void 0 || item === null) {
			item = 1;
		}
		console.log(item);
	};
	bar.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return bar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
	function baz() {
		return baz.__ks_rt(this, arguments);
	};
	baz.__ks_0 = function(item = 1) {
		console.log(item);
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
	qux.__ks_0 = function(item) {
		if(item === void 0 || item === null) {
			item = 1;
		}
		console.log(item);
	};
	qux.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return qux.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function quux() {
		return quux.__ks_rt(this, arguments);
	};
	quux.__ks_0 = function(item = 1) {
		console.log(item);
	};
	quux.__ks_rt = function(that, args) {
		const t0 = value => Type.isNumber(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return quux.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};