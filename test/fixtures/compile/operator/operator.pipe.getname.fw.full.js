const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const User = Helper.alias(value => Type.isDexObject(value, 1, 0, {name: Type.isString, supervisorId: value => Type.isNumber(value) || Type.isNull(value)}));
	function getSupervisorName() {
		return getSupervisorName.__ks_rt(this, arguments);
	};
	getSupervisorName.__ks_0 = function(enteredId) {
		if(enteredId === void 0) {
			enteredId = null;
		}
		let __ks_0, __ks_1, __ks_2;
		return Type.isValue(enteredId) ? (__ks_2 = repository.findById(parseInt(enteredId)), Type.isValue(__ks_2) ? (__ks_1 = __ks_2.supervisorId, Type.isValue(__ks_1) ? (__ks_0 = repository.findById(__ks_1), Type.isValue(__ks_0) ? __ks_0.name : null) : null) : null) : null;
	};
	getSupervisorName.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return getSupervisorName.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};