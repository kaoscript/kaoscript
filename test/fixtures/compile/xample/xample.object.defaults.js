const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = {};
	__ks_Object.__ks_sttc_defaults_0 = function(args) {
		return __ks_Object.__ks_sttc_merge_0([new OBJ(), ...args]);
	};
	__ks_Object.__ks_sttc_merge_0 = function(args) {
		return new OBJ();
	};
	__ks_Object._sm_defaults = function() {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(Helper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Object.__ks_sttc_defaults_0(Helper.getVarargs(arguments, 0, pts[1]));
		}
		if(Object.defaults) {
			return Object.defaults(...arguments);
		}
		throw Helper.badArgs();
	};
	__ks_Object._sm_merge = function() {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(arguments, pts, idx);
		let pts;
		if(Helper.isVarargs(arguments, 0, arguments.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_Object.__ks_sttc_merge_0(Helper.getVarargs(arguments, 0, pts[1]));
		}
		if(Object.merge) {
			return Object.merge(...arguments);
		}
		throw Helper.badArgs();
	};
	function init() {
		return init.__ks_rt(this, arguments);
	};
	init.__ks_0 = function(data) {
		return __ks_Object.__ks_sttc_defaults_0([data, (() => {
			const d = new OBJ();
			d.foo = "bar";
			return d;
		})()]);
	};
	init.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return init.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};