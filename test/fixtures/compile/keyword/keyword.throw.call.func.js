const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.struct(function(ok, value = null) {
		const _ = new OBJ();
		_.ok = ok;
		_.value = value;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isBoolean;
		if(args.length >= 1 && args.length <= 2) {
			if(t0(args[0])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	function __ks_throw_1() {
		return __ks_throw_1.__ks_rt(this, arguments);
	};
	__ks_throw_1.__ks_0 = function(expected) {
		throw new Error("Expecting \"" + expected + "\"");
	};
	__ks_throw_1.__ks_1 = function(expecteds) {
		throw new Error(Helper.concatString("Expecting \"", expecteds.join("\", \""), "\""));
	};
	__ks_throw_1.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_throw_1.__ks_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_throw_1.__ks_1.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(event) {
		__ks_throw_1.apply(null, [].concat(event.value));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isStructInstance(value, Event);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};