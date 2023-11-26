const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.bitmask(Object, ["NoFeatures", 0n, "Feature1", 1n, "Feature2", 2n, "Feature3", 4n, "Feature4", 8n, "Feature32", 2147483648n, "Feature48", 140737488355328n]);
};