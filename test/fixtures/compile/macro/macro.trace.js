module.exports = function() {
	const runTime = Math.floor(Date.now() / 1000);
	const age = runTime - 1362096000;
	console.log("Right now it's " + runTime + ", and this build is " + age + " seconds old");
};