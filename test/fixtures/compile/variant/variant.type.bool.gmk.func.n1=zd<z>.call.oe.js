const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isEvent: (value, mapper, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
			if(!Type.isBoolean(variant)) {
				return false;
			}
			if(filter && !filter(variant)) {
				return false;
			}
			if(variant) {
				return Type.isDexObject(value, 0, 0, {value: mapper[0], line: value => Type.isNumber(value) || Type.isNull(value), column: value => Type.isNumber(value) || Type.isNull(value)});
			}
			else {
				return Type.isDexObject(value, 0, 0, {expecting: value => Type.isString(value) || Type.isNull(value)});
			}
		}})
	};
	const NO = (() => {
		const o = new OBJ();
		o.ok = false;
		return o;
	})();
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(first) {
		if(first === void 0 || first === null) {
			first = NO;
		}
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isEvent(value, [Type.any]) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return quxbaz.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	quxbaz.__ks_0((() => {
		const o = new OBJ();
		o.ok = false;
		return o;
	})());
};