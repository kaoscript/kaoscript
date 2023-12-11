const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const State = Helper.bitmask(Number, ["Step0", 0, "Step1", 1, "Step2", 2, "Step3", 4, "Step4", 8]);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(state) {
		let result = State.Step0;
		if((state & State.Step1) != 0) {
			result = State(result | State.Step1);
		}
		return result;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isBitmaskInstance(value, State);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};