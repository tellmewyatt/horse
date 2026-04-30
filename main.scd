(s.options.memSize = 8192 * 100;
s.options.numWireBufs = 1024;
s.options.numOutputBusChannels = 8;
s.options.hardwareBufferSize = 2048;
Server.supernova;
s.reboot;
"./config.scd".loadRelative;
"./noteMap.scd".loadRelative;
"./aMap.scd".loadRelative;
"./bMap.scd".loadRelative;
"./movementOne.scd".loadRelative;
~noteMap.switchTo(\a);
~noteMap.colorAllPads;
~maxOsc = NetAddr.new("127.0.0.1", 5000);
~setupEffects = {
	~reverb = Synth(\reverb, [\in, ~busses.reverb]);
	~plateVerb = Synth(\reverb,  [\in, ~busses.plateVerb, \room, 0.1, \damp, 1, \amp, 1.5]);
	~scaleVideoRGB = Synth.tail(s, \videoControl3, [\in, ~busses.video.rgbScales, \out, ~busses.video.rgbScales]);
	~scaleVideoNoise = Synth.tail(s, \videoControl, [\in, ~busses.video.xfade, \out, ~busses.video.xfade]);
	~rgbOffset = Synth(\rgbOffset, [\out, ~busses.video.rgbScales]);
	~saturationOffset = Synth(\videoOffset, [\out, ~busses.video.saturation]);
	// Create the parallel group that will persist forever
	~parGroup = ParGroup(s);
	~maxOsc.sendMsg('/preset', 1);
	~busses.video.xfade.set(0);
	~sendVideoData = r {
		loop {
			~busses.video.rgbScales.get({ | value |
				~maxOsc.sendMsg("/scalebias/rscale", value[0]);
				~maxOsc.sendMsg("/scalebias/gscale", value[1]);
				~maxOsc.sendMsg("/scalebias/bscale", value[2]);
			});
			~busses.video.xfade.get({ | value |
				~maxOsc.sendMsg("/xfade/xfade", value);
			});
			~busses.video.saturation.get({ | value |
				~maxOsc.sendMsg("/brcosa/saturation", value);
			});
			0.01.wait;
		}
	}.play;
};
s.waitForBoot {
	// Run the setup
	r {
		"synthdefs.scd".loadRelative;
		// Create the effects busses
		~busses = ();
		// Create the reverb bus
		~busses.reverb = Bus.audio(s, s.options.numOutputBusChannels);
		// Create the plateVerb bus
		~busses.plateVerb = Bus.audio(s, s.options.numOutputBusChannels);
		// Controls RGB video
		~busses.video= (
			rgbScales: Bus.control(s, 3),
			xfade: Bus.control(s, 1),
			saturation: Bus.control(s, 1)
		);
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
		~samples.meo = Buffer.readChannel(s, "./audio/meo-1.wav".resolveRelative, channels:[0]);
		~samples.neighs = PathName("audio/horse-neighs".resolveRelative).entries.collect { | path |
			Buffer.readChannel(s, path.absolutePath, channels:[0])
		};
		~setupEffects.();
	}.play;

}
)
