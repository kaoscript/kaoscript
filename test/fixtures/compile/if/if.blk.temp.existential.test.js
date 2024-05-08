const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(scope, name) {
		let variable;
		let __ks_0;
		if((Type.isValue(__ks_0 = scope.getVariable(name)) ? (variable = __ks_0, true) : false) && ((variable.name() !== name) || (variable.scope() !== scope))) {
			return variable.discard();
		}
		else {
			return null;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};