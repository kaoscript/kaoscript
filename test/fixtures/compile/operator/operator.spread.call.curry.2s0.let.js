const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = [1, 2];
	const bar = [];
	bar.push(0, ...foo);
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
	let machine = "tesla";
	let directory = "xfer";
	let user = "john";
	let info = [directory, " ", user, ": "];
	let logHello = Helper.curry((that, fn, ...args) => {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return fn[0](Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	}, (__ks_0) => log.__ks_0([machine, ":", ...info, ...__ks_0]));
	logHello.__ks_0(["foo"]);
};