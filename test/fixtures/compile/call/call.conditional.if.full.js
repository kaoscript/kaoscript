const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(_3d) {
		quxbaz.__ks_0(1, 1, (_3d === true) ? 1 : void 0);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(x, y, z = 0) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length >= 2 && args.length <= 3) {
			if(t0(args[0]) && t0(args[1])) {
				return quxbaz.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};