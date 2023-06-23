const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isCoord: value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(coord) {
		const data = (() => {
			const o = new OBJ();
			Helper.concatObject(o, coord);
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isCoord;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};