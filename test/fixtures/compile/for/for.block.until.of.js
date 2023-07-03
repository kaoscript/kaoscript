const {Helper, OBJ} = require("@kaoscript/runtime");
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
		if(value === "chani") {
			break;
		}
		console.log(Helper.concatString(key, " likes ", value));
	}
};