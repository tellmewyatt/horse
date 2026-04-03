(s.options.memSize = 8192 * 100;
s.options.numWireBufs = 1024;
s.options.numOutputBusChannels = 8;
s.options.hardwareBufferSize = 1024;
Server.supernova;
s.reboot;
MIDIIn.connectAll;
~lpxOut = MIDIOut.newByName("Launchpad X", "LPX MIDI In");
~lpxOut.latency = 0;
~colorAllPads = { | function |
	8.collect { | row |
		8.collect { | col |
			var nn = row * 10 + col + 11;
			~lpxOut.noteOn(0, nn, function.(nn))
		}
	}
};
~maxOsc = NetAddr.new("127.0.0.1", 5000);
s.waitForBoot {
	// Run the setup
	r {
		"synthdefs.scd".loadRelative;
		// Create the effects busses
		~busses = ();
		// Create the reverb bus
		~busses.reverb = Bus.audio(s, s.options.numOutputBusChannels);
		~samples = ();
		~convolutionBuffers =
		40.collect {
			var buf = Buffer.alloc(s, 1024, 1);
			buf;
		};
		s.sync;
		~convolutionBuffers.collect { | buf |
			buf.setn(0, 1024.collect { rrand(0, 1) }).normalize;
		};
		~samples.whatami = Buffer.readChannel(s, "audio/03.flac".resolveRelative, channels:[0]);
		~samples.gallopsL = Buffer.readChannel(s, "audio/gallops.wav".resolveRelative, channels:[0]);
		~samples.gallopsR = Buffer.readChannel(s, "audio/gallops.wav".resolveRelative, channels:[1]);
		~samples.neighs = PathName("audio/horse-neighs".resolveRelative).entries.collect { | path |
			Buffer.readChannel(s, path.absolutePath, channels:[0])
		};
	}.play;

}
)
(
~reverb = Synth(\reverb, [\in, ~busses.reverb]);
// Create the parallel group that will persist forever
~parGroup = ParGroup(s);
~routines = ();
~routines.attackFromEverywhere = r {
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

~routines.longIntro = r {
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
	~routines.attackFromEverywhere.play;
};
~config = (
	sinHitPanRange: 0.125,
	reverbSend: 0.5,
	bassAmp: 0.4,
	noteOffColor: 1,
);
~colorAllPads.({ ~config.noteOffColor });
// This is a 8 x 8 map from [36..99]
~noteOffMap = ();
~noteOnMap = (
	// Column 1
	81: { ~routines.longIntro.play; },
	71: { ~routinesattackFromEverywhere.play; },
	61: { | velocity |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.whatami,
			\freqRatio, 0.6,
			\freq, 100,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\amp, 0.2 * velocity,
			\pan, 0,
			\oscDefect, 0.1
		], ~parGroup);
	},
	51: {
		Synth(\horseGallop, [
			\bufnumL, ~samples.gallopsL,
			\bufnumR, ~samples.gallopsR,
			\rateScale, rrand(0.8, 1.2),
			\dur, rrand(10, 20),
			\pan, rrand(-1, 1),
			\spread, rrand(0, 1.0)

		], ~parGroup);
	},
	41: {
		var samp = ~samples.neighs.choose;
		Synth(\horseGallop, [
			\bufnumL, samp,
			\bufnumR, samp,
			\rateScale, rrand(0.8, 1.2),
			\dur, rrand(1, 3),
			\pan, rrand(-1.0, 1),
			\spread, 0,
			\grainRate, 5,
			\grainDur, 0.6

		]);
	},
	31: { | velocity |
		Synth(\percussiveNoise, [\bufnum, ~convolutionBuffers.choose, \amp, 0.1 * velocity, \release, 0.2 * velocity], ~parGroup);
	},
	21: { | vel |
		Synth(\bassDrum, [\amp, vel * 0.5, \releaseTime, 4]);
		~maxOsc.sendMsg("/bassDrumHit", vel);
	},
	11: { | velocity |
		var createSynth = {
			~vocoder = Synth(\vocoder, [\amp, 2, \oscDefect, 1]);
			NodeWatcher.register(~vocoder);
		};
		if(~vocoder == nil, createSynth, {
			if(~vocoder.isPlaying, {
				~vocoder.release;
				~vocoder = nil;
			}, createSynth)
		});
	},
	// Column 2
	12: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbBus, ~busses.reverb,
			\reverbSend, ~config.reverbSend,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/sinHit", vel);
	},
	22: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/sinHit", vel);
	},
	32: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/sinHit", vel);
	},
	42: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1800,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/sinHit", vel);
	},
	52: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 2400,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/sinHit", vel);
	},
	62: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3000,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/sinHit", vel);
	},
	72: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/sinHit", vel);
	},
	82: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~convolutionBuffers.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 4200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/sinHit", vel);
	},
	// Column 3
	13: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/mistHit", vel);
	},
	23: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/mistHit", vel);
	},
	33: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/mistHit", vel);
	},
	43: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 1800,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/mistHit", vel);
	},
	53: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 2400,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/mistHit", vel);
	},
	63: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3000,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/mistHit", vel);
	},
	73: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3000,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/mistHit", vel);
	},
	83: { | vel |
		Synth(\normalizedVocoder, [
			\bufnum, ~samples.neighs.choose,
			\freqRatio, 0.6,
			\freq, [50, 100, 150, 200, 250, 300].choose + 3600,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, ~config.reverbSend,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0.1,
			\amp, 0.2 * vel
		], ~parGroup);
		~maxOsc.sendMsg("/mistHit", vel);
	},


	// Column 4
	84: { | vel |
		Synth(\crazyFall, [\dur, 10, \amp, 0.1 * vel, \pan, rrand(-1.0, 1), \startFreq, s.sampleRate]);
		~maxOsc.sendMsg("/crazyFall", vel);
	},
	74: { | vel |
		Synth(\crazyFall, [\dur, 10, \amp, 0.1 * vel, \pan, rrand(-1.0, 1), \startFreq, 1000, \endFreq, 20000]);
		~maxOsc.sendMsg("/crazyFall", vel);
	},
	64: { | vel |
		~noteOffMap[64] = Synth(\noisyCross, [\bufnum, ~samples.neighs.choose, \amp, 0.2]);
	},
	54: { | vel |
		~noteOffMap[54] = Synth(\noisyCross, [\bufnum, ~samples.gallopsL, \amp, 0.5]);
	},
	44: { | vel |
		~noteOffMap[44] = Synth(\normalizedVocoderHeld, [
			\bufnum, ~samples.gallopsL,
			\freqRatio, 0.6,
			\freq, 200,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, 0,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0,
			\amp, 0.1 * vel,
			\attack, 4,
			\release, 4
		], ~parGroup);
	},
	34: { | vel |
		~noteOffMap[34] = Synth(\normalizedVocoderHeld, [
			\bufnum, ~samples.gallopsL,
			\freqRatio, 0.6,
			\freq, 200 * 6.5.midiratio                                                                                                                                                                                                                                                                                                    ,
			\convolutionBuffer, ~convolutionBuffers.choose,
			\reverbSend, 0,
			\reverbBus, ~busses.reverb,
			\pan, rrand(-1.0, 1),
			\oscDefect, 0,
			\amp, 0.1 * vel,
			\attack, 4,
			\release, 4
		], ~parGroup);
	},
	24: { | vel |
		~noteOffMap[24] = Synth(\bouncyBass, [\freq, 30.midicps, \amp, ~config.bassAmp * vel]);
	},
	14: { | vel |
		~noteOffMap[14] = Synth(\bouncyBass, [\freq, 25.midicps, \amp, ~config.bassAmp * vel]);
	},


	// Column 5
	15: { | vel |
		~noteOffMap[15] = Synth(\sinPulse, [\freq, 200, \pan, rrand(-1.0, 1)]);
	},
	25: { | vel |
		~noteOffMap[25] = Synth(\sinPulse, [\freq, 300, \pan, rrand(-1.0, 1)]);
	},
	35: { | vel |
		~noteOffMap[35] = Synth(\sinPulse, [\freq, 350, \pan, rrand(-1.0, 1)]);
	},
	45: { | vel |
		~noteOffMap[45] = Synth(\sinPulse, [\freq, 266, \pan, rrand(-1.0, 1)]);

	},
	55: { | vel |
		~noteOffMap[55] = Synth(\sinPulse, [\freq, 295, \pan, rrand(-1.0, 1)]);
	},
	65: { | vel |
		~noteOffMap[65] = Synth(\sinPulse, [\freq, 400, \pan, rrand(-1.0, 1)]);
	},
	75: { | vel |
		~noteOffMap[75] = Synth(\sinPulse, [\freq, 420, \pan, rrand(-1.0, 1)]);
	},
	85: { | vel |
		~noteOffMap[85] = Synth(\sinPulse, [\freq, 490, \pan, rrand(-1.0, 1)]);
	}



);
MIDIdef.noteOn(\noteOns, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	[nn, vel].postln;
	nn.postln;
	~lpxOut.noteOn(0, nn, rrand(0, 127));
	~noteOnMap[nn].(vel / 127);
});
MIDIdef.noteOff(\noteOffs, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	nn.postln;
	~lpxOut.noteOn(0, nn, ~config.noteOffColor);
	~noteOffMap[nn].release;
});

)
~routines.longIntro.play;
Synth(\bouncyBass)