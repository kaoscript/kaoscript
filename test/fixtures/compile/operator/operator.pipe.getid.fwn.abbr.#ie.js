const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function getSupervisorId() {
		return getSupervisorId.__ks_rt(this, arguments);
	};
	getSupervisorId.__ks_0 = function(enteredId) {
		if(enteredId === void 0) {
			enteredId = null;
		}
		let __ks_0, __ks_1;
		return Type.isValue(__ks_1 = Type.isValue(enteredId) ? (__ks_0 = parseInt(enteredId), (Number.isFinite(__ks_0) === true) ? __ks_0 : null) : null) ? __ks_1 : 0;
	};
	getSupervisorId.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return getSupervisorId.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};