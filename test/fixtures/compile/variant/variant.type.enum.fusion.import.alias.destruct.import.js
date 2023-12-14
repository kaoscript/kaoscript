require("kaoscript/register");
const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	var {PersonKind, __ksType: __ksType0} = require("./.variant.type.enum.fusion.export.alias.ks.j5k8r9.ksb")();
	function Director() {
		return Director.__ks_rt(this, arguments);
	};
	Director.__ks_0 = function({start, end}) {
		return (() => {
			const o = new OBJ();
			o.kind = PersonKind.Director;
			o.start = start;
			o.end = end;
			return o;
		})();
	};
	Director.__ks_rt = function(that, args) {
		const t0 = __ksType0[1];
		if(args.length === 1) {
			if(t0(args[0])) {
				return Director.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};