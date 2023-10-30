const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function log() {
		return log.__ks_rt(this, arguments);
	};
	log.__ks_0 = function(args) {
		console.log(...args);
	};
	log.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return log.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(info) {
		const logHello = Helper.curry((that, fn, ...args) => {
			const t0 = Type.isValue;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return fn[0](Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}, (__ks_0) => log.__ks_0([...info, ...__ks_0]));
		logHello.__ks_0(["foo"]);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, Type.isString);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};