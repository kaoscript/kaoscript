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
		if(!Type.isValue(enteredId)) {
			return null;
		}
		let employee, __ks_0;
		if((Type.isValue(__ks_0 = repository.findById(parseInt(enteredId))) ? (employee = __ks_0, true) : false) && Type.isValue(employee.supervisorId)) {
			let supervisor;
			if((Type.isValue(__ks_0 = repository.findById(employee.supervisorId)) ? (supervisor = __ks_0, true) : false)) {
				return supervisor.name;
			}
		}
		return null;
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