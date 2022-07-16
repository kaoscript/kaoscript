module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(args) {
		return 0;
	};
	foobar.__ks_rt = function(that, args) {
		return foobar.__ks_0.call(that, Array.from(args));
	};
};