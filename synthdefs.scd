SynthDef(\playSample, { | amp=0.2, out=0, pan=0, rate=1, bufnum |
	Out.ar(out,
		PanAz.ar(s.options.numOutputBusChannels,
			PlayBuf.ar(1, bufnum, rate * BufRateScale.kr(bufnum), 1, 0, 0, doneAction: 2),
			pan,
			amp,
			2,
			0)
	);
}).add;
SynthDef(\horseGallop, { | bufnumL, bufnumR, dur=5, spread=1, amp=0.2, pan = 0, fadeTime=0.2, rateScale=1.4, out=0, grainRate=2, grainDur=1 |
	var sig;
	sig = SplayAz.ar(s.options.numOutputBusChannels, [
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnumL, BufRateScale.kr(bufnumL) * rateScale, Line.kr(0, 0.9, dur)) * EnvGen.kr(Env([0,1,1,0], [fadeTime, dur - (fadeTime*2), fadeTime])),
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnumR, BufRateScale.kr(bufnumR) * rateScale, Line.kr(0, 0.9, dur)) * EnvGen.kr(Env([0,1,1,0], [fadeTime, dur - (fadeTime*2), fadeTime]))
	], Rand(0.1, 1), amp, 2, pan);
	Out.ar(out, sig);
}).add;
SynthDef(\grainBuf, { | bufnum, dur=5, spread=1, amp=0.2, pan = 0, fadeTime=0.2, rateScale=1.4, out=0, grainRate=2, grainDur=1 |
	var sig;
	sig = SplayAz.ar(s.options.numOutputBusChannels, [
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnum, BufRateScale.kr(bufnum) * rateScale, Line.kr(0, 0.9, dur)) * EnvGen.kr(Env([0,1,1,0], [fadeTime, dur - (fadeTime*2), fadeTime])),
		GrainBuf.ar(1, Impulse.kr(grainRate), grainDur, bufnum, BufRateScale.kr(bufnum) * rateScale, Line.kr(0, 0.9, dur)) * EnvGen.kr(Env([0,1,1,0], [fadeTime, dur - (fadeTime*2), fadeTime]))
	], Rand(0.1, 1), amp, 2, pan);
	Out.ar(out, sig);
}).add;
SynthDef(\vocoder, { | out = 0, pan=0, amp = 1, oscDefect=0, freq=100, gate=1, reverbBus, reverbSend=0 |
	var sig = SoundIn.ar(0, 1);
	var pitch = Pitch.kr(sig)[0];
	// Analysis
	var filters = BPF.ar(sig, 200.collect { | i | (i + 1) * 100 }, 0.1, 1);
	var amps = filters.collect { | item | Amplitude.ar(item) };
	// Resynthesis
	var outsig =  amps.collect ({ | amp, i |
		SinOsc.ar((i+ 1) * pitch * (1 + (Rand(-1.0, 1) * oscDefect)), 0, amp);
	}).sum * 2;
	var env = EnvGen.kr(Env.asr(0.01, 1, 0.01), gate, doneAction: 2);
	outsig = outsig + sig;
	outsig = PanAz.ar(s.options.numOutputBusChannels, outsig, pan, amp * env);
	Out.ar(reverbBus, outsig * reverbSend);
	Out.ar(out, outsig);
}).add;
SynthDef(\normalizedVocoder, { | amp=0.2, gate=1, freq=200, out=0, bufnum, pan=0, freqRatio=1, convolutionBuffer, oscDefect=0, envCurve= -4, reverbBus, reverbSend=0, reverbPreDelay=0 |
	// Vocoder section
	var insig = PlayBuf.ar(
		1,
		bufnum,
		BufRateScale.kr(bufnum) * freqRatio
	);
	// Analysis
	var filters = BPF.ar(insig, 100.collect { | i | (i + 1) * 100 * freqRatio }, 0.1, 1);
	var amps = filters.collect { | item | Amplitude.ar(item) };
	// Resynthesis
	var sig =  amps.collect ({ | amp, i |
		SinOsc.ar((i+ 1) * freq * (1 + (Rand(-1.0, 1) * oscDefect)), 0, amp);
	}).sum * 2;

	var attackTime = 1.5 / freqRatio;
	var env = EnvGen.kr(
		Env.perc(
			attackTime,
			BufDur.kr(bufnum) / freqRatio - attackTime,
			1,
			envCurve
		),
		gate);
	var doneEnv = EnvGen.kr(
		Env.perc(
			attackTime,
			BufDur.kr(bufnum) / freqRatio - attackTime + 10
		),
		gate, doneAction: 2);
	sig = Normalizer.ar(sig, 0.5, 0.001) + sig;
	sig = sig +HPF.ar(Convolution2.ar(sig, convolutionBuffer, 0, 1024) * 0.1, 100);
	sig = PanAz.ar(
		s.options.numOutputBusChannels,
		sig,
		pan,
		0.5 * amp * env
	);
	Out.ar(reverbBus,
		DelayN.ar(reverbSend * sig, 0.2, 2 * reverbPreDelay)
	);
	Out.ar(out, sig);
}).add;
SynthDef(\percussiveNoise, { | amp = 1, pan=0, bufnum, out=0, gate=1, release =0.01 |
	var env = EnvGen.kr(Env([0,1,1,0], [0, 15, 0]), gate, doneAction: 2);
	var sig = PlayBuf.ar(1,bufnum) * 0.8 * EnvGen.ar(Env.perc(0,release));
	sig = Pan2.ar(sig, pan, amp);
	sig = HPF.ar(FreeVerb2.ar(sig, sig, Rand(0.2, 0.5), 1, ExpRand(0.1, 1)), 800);
	Out.ar(out, sig * env);
}).add;
SynthDef(\bassDrum, { | freq = 40, amp = 1, out=0, releaseTime=1 |
	var sig = SplayAz.ar(
		s.options.numOutputBusChannels,
		SinOsc.ar(Rand(1, 4! 20) * freq, 0.5*pi) * amp * EnvGen.kr(Env.perc(0.001, releaseTime), 1, doneAction: 2) * 0.3);
	Out.ar(out, sig);
}).add;
SynthDef(\reverb, { | in, out=0, room=1, damp=0.5, amp=1 |
	Out.ar(
		out,
		FreeVerb.ar(
			In.ar(in, s.options.numOutputBusChannels),
			1,
			room, damp, amp
		)
	);
}).add;

		