(s.options.memSize = 8192 * 100;
s.options.numWireBufs = 1024;
s.options.numOutputBusChannels = 8;
s.options.hardwareBufferSize = 1024;
Server.supernova;
s.reboot;
"./noteMap.scd".loadRelative;
"./aMap.scd".loadRelative;
"./bMap.scd".loadRelative;
"./config.scd".loadRelative;
"./movementOne.scd".loadRelative;
~noteMap.switchTo(\a);
~noteMap.colorAllPads;
~maxOsc = NetAddr.new("127.0.0.1", 5000);
s.waitForBoot {
	// Run the setup
	r {
		"synthdefs.scd".loadRelative;
		// Create the effects busses
		~busses = ();
		// Create the reverb bus
		~busses.reverb = Bus.audio(s, s.options.numOutputBusChannels);
		// Controls RGB video
		~busses.video= (
			rgbScales: Bus.control(s, 3),
			noiseLevel: Bus.control(s, 1),
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
	}.play;

}
)
(
~reverb = Synth(\reverb, [\in, ~busses.reverb]);
~scaleVideoRGB = Synth.tail(s, \videoControl3, [\in, ~busses.video.rgbScales, \out, ~busses.video.rgbScales]);
~scaleVideoNoise = Synth.tail(s, \videoControl, [\in, ~busses.video.noiseLevel, \out, ~busses.video.noiseLevel]);
~rgbOffset = Synth(\rgbOffset, [\out, ~busses.video.rgbScales]);
~saturationOffset = Synth(\videoOffset, [\out, ~busses.video.saturation]);
// Create the parallel group that will persist forever
~parGroup = ParGroup(s);
~sendVideoData = r {
	loop {
		~busses.video.rgbScales.get({ | value |
			~maxOsc.sendMsg("/rscale", value[0]);
			~maxOsc.sendMsg("/gscale", value[1]);
			~maxOsc.sendMsg("/bscale", value[2]);
		});
		~busses.video.noiseLevel.get({ | value |
			~maxOsc.sendMsg("/noiseLevel", value);
		});
		~busses.video.saturation.get({ | value |
			~maxOsc.sendMsg("/saturation", value);
		});
		0.01.wait;
	}
}.play;
)