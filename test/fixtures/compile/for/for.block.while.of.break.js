const {Helper, OBJ, Operator} = require("@kaoscript/runtime");
module.exports = function() {
	const likes = (() => {
		const o = new OBJ();
		o.leto = "spice";
		o.paul = "chani";
		o.duncan = "murbella";
		return o;
	})();
	for(const key in likes) {
		const value = likes[key];
		if(!(Operator.lte(value.length, 5))) {
			break;
		}
		console.log(Helper.concatString(key, " likes ", value));
	}
};