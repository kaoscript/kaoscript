const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Weekday = Helper.enum(Number, 2, "dayOfWeek", "printableName", "MONDAY", 1, 1, "Monday", "TUESDAY", 2, 2, "Tuesday", "WEDNESDAY", 3, 3, "Wednesday", "THURSDAY", 4, 4, "Thursday", "FRIDAY", 5, 5, "Friday", "SATURDAY", 6, 6, "Saturday", "SUNDAY", 7, 7, "Sunday");
	function print() {
		return print.__ks_rt(this, arguments);
	};
	print.__ks_0 = function(day) {
		console.log(day.printableName);
		if(day.dayOfWeek === 1) {
			console.log("It's Monday :(");
		}
	};
	print.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Weekday);
		if(args.length === 1) {
			if(t0(args[0])) {
				return print.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};