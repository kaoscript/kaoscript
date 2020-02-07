var {Helper, Operator} = require("@kaoscript/runtime");
module.exports = function() {
	const runTime = Math.floor(Operator.division(Date.now(), 1000));
	const age = Operator.subtraction(runTime, 1362096000);
	console.log(Helper.concatString("Right now it's ", runTime, ", and this build is ", age, " seconds old"));
};