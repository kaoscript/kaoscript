const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function likes() {
		return likes.__ks_rt(this, arguments);
	};
	likes.__ks_0 = function() {
		return (() => {
			const d = new Dictionary();
			d.leto = "spice";
			d.paul = "chani";
			d.duncan = "murbella";
			return d;
		})();
	};
	likes.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return likes.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	{
		let __ks_0 = likes.__ks_0();
		for(let key in __ks_0) {
			let value = __ks_0[key];
			console.log(Helper.concatString(key, " likes ", value));
		}
	}
};