require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var {NodeKind, __ksType: __ksType0} = require("../variant/.variant.type.enum.export.wfusion.ks.j5k8r9.ksb")();
	function prepare() {
		return prepare.__ks_rt(this, arguments);
	};
	prepare.__ks_0 = function(content) {
		const node = Helper.assert(JSON.parse(content), "\"NodeData\"", 0, value => __ksType0[1](value, true));
	};
	prepare.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return prepare.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};