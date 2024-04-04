const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Date = {};
	__ks_Date.__ks_sttc_today_0 = function() {
		return __ks_Date.__ks_func_midnight_0.call(new Date());
	};
	__ks_Date.__ks_func_midnight_0 = function() {
		this.setHours(0);
		this.setMinutes(0);
		this.setSeconds(0);
		this.setMilliseconds(0);
		return this;
	};
	__ks_Date._sm_today = function() {
		if(arguments.length === 0) {
			return __ks_Date.__ks_sttc_today_0();
		}
		if(Date.today) {
			return Date.today(...arguments);
		}
		throw Helper.badArgs();
	};
	__ks_Date._im_midnight = function(that, ...args) {
		return __ks_Date.__ks_func_midnight_rt(that, args);
	};
	__ks_Date.__ks_func_midnight_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Date.__ks_func_midnight_0.call(that);
		}
		if(that.midnight) {
			return that.midnight(...args);
		}
		throw Helper.badArgs();
	};
	console.log(__ks_Date.__ks_sttc_today_0());
	console.log(__ks_Date.__ks_func_midnight_0.call(new Date()));
};