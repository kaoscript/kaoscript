module.exports = function() {
	var __ks_Date = {};
	__ks_Date.__ks_cons_1 = function() {
		return this;
	};
	__ks_Date.new = function() {
		if(arguments.length === 0) {
			return __ks_Date.__ks_cons_1.apply(new Date(), arguments);
		}
		else {
			return new (Function.bind.apply(Date, [null].concat(Array.prototype.slice.call(arguments))));
		}
	};
	function foobar() {
		var args = Array.prototype.slice.call(arguments, 0, arguments.length);
		var d = __ks_Date.new.apply(null, args);
	}
};