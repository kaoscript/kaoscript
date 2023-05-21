const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
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
		let employee = repository.findById(parseInt(enteredId));
		if(Type.isValue(employee) && Type.isValue(employee.supervisorId)) {
			let supervisor = repository.findById(employee.supervisorId);
			if(Type.isValue(supervisor)) {
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