const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = Helper.function((x = null, y) => {
		return [x, y];
	}, (fn, ...args) => {
		const t0 = () => true;
		const t1 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 2) {
			if(Helper.isVarargs(args, 0, args.length - 1, t0, pts = [0], 0) && Helper.isVarargs(args, 1, 1, t1, pts, 1) && te(pts, 2)) {
				return fn.call(null, Helper.getVararg(args, 0, pts[1]), Helper.getVararg(args, pts[1], pts[2]));
			}
		}
		throw Helper.badArgs();
	});
};