~noteMap.def(\opening, { | m |
	var getDistortionFactor = { | nPlaying, maxDistortion=20 |

		var env = Env([0,maxDistortion], 1, 3);
		env.at(nPlaying.linlin(1, 8, 0, 1));
	};
	var getCol5Func = { | freq |
		{ | vel, current |
			var synth= Synth(\sinPulse, [\freq, freq, \pan, rrand(-1.0, 1), \distortionFactor, 0]);
			current.toggleMap.collect { | synth |
				synth.set(\distortionFactor, getDistortionFactor.(current.toggleMap.size));
				synth.set(\panRateScale, current.toggleMap.size / 8);
			};
			synth;
		}
	};
	var col5ToggleOff = { | vel, current |
		current.toggleMap.collect { | synth |
			synth.set(\distortionFactor, getDistortionFactor.(current.toggleMap.size));
		};
	};
	// Column 1
	m.hit(61, { | velocity |
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
	});
	m.hit(51, {
		Synth(\horseGallop, [
			\bufnumL, ~samples.gallopsL,
			\bufnumR, ~samples.gallopsR,
			\rateScale, rrand(0.8, 1.2),
			\dur, rrand(10, 20),
			\pan, rrand(-1, 1),
			\spread, rrand(0, 1.0)

		], ~parGroup);
	});
	m.hit(41, {
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
	});
	m.hit(31, { | velocity |
		Synth(\percussiveNoise, [\bufnum, ~convolutionBuffers.choose, \amp, 0.1 * velocity, \release, 0.2 * velocity], ~parGroup);
	});
	m.hit(21, { | vel |
		Synth(\bassDrum, [\amp, vel * 0.5, \releaseTime, 4]);
		Synth(\videoHit, [\out, ~busses.video.saturation, \amp, vel * 10, \release, 4]);
	});
	m.toggle(11, { | velocity |
		Synth(\vocoder, [\amp, 2, \oscDefect, 1, \reverbBus, ~busses.reverb, \reverbSend, ~config.reverbSend]);
	});

	// Column 2
	8.collect { | i |

		m.hit(12 + (i * 10), { | vel |
			Synth(\normalizedVocoder, [
				\bufnum, ~convolutionBuffers.choose,
				\freqRatio, 0.6,
				\freq, [50, 100, 150, 200, 250, 300].choose + (600 * i),
				\convolutionBuffer, ~convolutionBuffers.choose,
				\reverbBus, ~busses.reverb,
				\reverbSend, ~config.reverbSend,
				\pan, rrand(~config.sinHitPanRange.neg, ~config.sinHitPanRange),
				\oscDefect, 0.1,
				\amp, 0.2 * vel
			], ~parGroup);
			Synth(\rgbHit, [\out, ~busses.video.rgbScales,
				\red, 0,
				\green, rrand(0.1, 1),
				\blue, rrand(0.1, 1), \amp, vel]);
		});
	};
	// Column 3
	8.collect { | i |

		m.hit(13 + (i * 10), { | vel |
			Synth(\normalizedVocoder, [
				\bufnum, ~samples.neighs.choose,
				\freqRatio, 0.6,
				\freq, [50, 100, 150, 200, 250, 300].choose + (i * 600),
				\convolutionBuffer, ~convolutionBuffers.choose,
				\reverbSend, ~config.reverbSend,
				\reverbBus, ~busses.reverb,
				\pan, rrand(-1.0, 1),
				\oscDefect, 0.1,
				\amp, 0.2 * vel
			], ~parGroup);
			Synth(\rgbHit, [\out, ~busses.video.rgbScales,
				\red, rrand(0.1, 0.5),
				\green, rrand(0.1, 1),
				\blue, rrand(0.1, 0.5), \attack, 1, \release, 1, \amp, vel]);
		});
	};
	// Column 4
	m.hit(84, { | vel |
		Synth(\crazyFall, [\dur, 10, \amp, 0.1 * vel, \pan, rrand(-1.0, 1), \startFreq, s.sampleRate]);
		Synth(\videoHit, [\out, ~busses.video.noiseLevel, \attack, 0.01, \release, 11, \amp, vel]);
	});
	m.hit(74, { | vel |
		Synth(\crazyFall, [\dur, 10, \amp, 0.1 * vel, \pan, rrand(-1.0, 1), \startFreq, 1000, \endFreq, 20000]);
		Synth(\videoHit, [\out, ~busses.video.noiseLevel, \attack, 0.01, \release, 11, \amp, vel]);
	});
	m.sustain(64, { | vel | Synth(\noisyCross, [\bufnum, ~samples.neighs.choose, \amp, 0.2]); });
	m.sustain(54, { | vel | Synth(\noisyCross, [\bufnum, ~samples.gallopsL, \amp, 0.5]); });
	m.sustain(44, { | vel |
		Synth(\normalizedVocoderHeld, [
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
	});
	m.sustain(34, { | vel |
		Synth(\normalizedVocoderHeld, [
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
	});
	// Column 5
	m.toggle(15, getCol5Func.(200));
	m.toggle(25, getCol5Func.(300));
	m.toggle(35, getCol5Func.(350));
	m.toggle(45, getCol5Func.(266));
	m.toggle(55, getCol5Func.(295));
	m.toggle(65, getCol5Func.(400));
	m.toggle(75, getCol5Func.(420));
	m.toggle(85, getCol5Func.(490));
	8.do { | i |
		m.toggleOff(15 + (i * 10), col5ToggleOff);
	};


	// Pad Colors
	m.colorPad({ | nn |
		var color;
		var alternate = nn.asString[0].digit % 2;
		if(nn + alternate % 2 == 0) {
			color = 120
		}
		{
			color = 21
		};
		color;
	});
	m.colorPadActive({ | nn |
		var color = rrand(0, 127);
		if (nn % 10 == 5) {
			color = ~config.toggledPadColor;
		};
		color;
	});
});