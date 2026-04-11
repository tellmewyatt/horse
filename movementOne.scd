~movementOne = ();
~movementOne.attackFromEverywhere = r {
	var freqRatio = 0.1;
	var oscDefect = 0;
	while  { freqRatio <= 0.7 } {
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.whatami,
			\freqRatio, freqRatio,
			\freq, 450 * [1.6, 1.7, 3.9, 4.3].choose /8,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, rrand(0.1, 1),
			\reverbBus, ~busses.reverb,
			\reverbPreDelay, rrand(0.0, 1),
			\pan, rrand(-1.0, 1),
			\oscDefect, oscDefect
		], ~parGroup);
		([3,5,7, 11].choose / (freqRatio * 10) ).wait;
		freqRatio = freqRatio + 0.01;
		oscDefect = oscDefect + 0.01;
	};
};

~movementOne.longIntro = r {
	var divRatio = 16;
	var timeElapsed = 0;
	"Playing long intro".postln;
	Synth(\playSample, [\bufnum, ~samples.neighs[0], \amp, 0.2, \pan, 0.125]);
	Synth(\horseGallop, [
		\bufnumL, ~samples.gallopsL,
		\bufnumR, ~samples.gallopsR,
		\rateScale, 1,
		\dur, 20,
		\pan, rrand(-1, 1),
		\spread, rrand(0, 1.0)
	], ~parGroup);
	5.wait;
	while { divRatio >= 1 } {
		"while still".postln;
		divRatio.postln;
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.whatami,
			\freqRatio, 0.01,
			\freq, 450 / divRatio,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, rrand(0.1, 1),
			\reverbBus, ~busses.reverb,
			\reverbPreDelay, rrand(0, 1.0),
			\pan, rrand(-1.0, 1),
			\oscDefect, 0

		], ~parGroup);
		divRatio = divRatio / 2;
		(divRatio * 4).wait;
	};
	Pbindef(\horseGallops,
		\instrument, \horseGallop,
		\bufnumL, ~samples.gallopsL,
		\bufnumR, ~samples.gallopsR,
		\rateScale, Pwhite(0.7, 1.5),
		\dur, Pwhite(20, 30),
		\delta, Pwhite(20, 40),
		\pan, Pwhite(-1.0, 1),
		\spread, Pwhite(0, 1.0)
	).play;
	Pbindef(\horseNeighs,
		\instrument, \grainBuf,
		\bufnum, Prand(~samples.neighs, inf),
		\rateScale, Pwhite(0.8, 1.2),
		\dur, Pwhite(1, 2),
		\pan, Pwhite(-1.0, 1),
		\spread, 0,
		\grainRate, 5,
		\grainDur, 0.6,
		\amp, 0.1,
		\delta, Pwhite(20, 40)
	).play;
	120.do {
		timeElapsed = timeElapsed + 1;
		timeElapsed.postln;
		1.wait;
	};
	Pbindef(\horseGallops).stop;
	Pbindef(\horseNeighs).stop;
	~movementOne.attackFromEverywhere.play;
};