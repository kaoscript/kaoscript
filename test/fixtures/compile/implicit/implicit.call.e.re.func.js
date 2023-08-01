const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	function test() {
		return test.__ks_rt(this, arguments);
	};
	test.__ks_0 = function(color) {
		return false;
	};
	test.__ks_1 = function(colors) {
		return false;
	};
	test.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Color);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 1) {
			if(t0(args[0])) {
				return test.__ks_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return test.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		if(test.__ks_0(Color.Red)) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};