~noteMap.def(\b, { | m |
	// Turns off the previously held notes if they are on
	var getCol5Func = { | freq |
		{ | vel | Synth(\meoCircles, [\bufnum, ~samples.meo, \playbackRate, freq/205]); }
	};
	var enabledRows = Set();
	var toggleGroups = ();
	var togglePrevious = { | nn, vel |
		var map = ~noteMap.noteMaps.a;
		if(map.toggleMap[nn].notNil) {
			map.onMap[nn].(vel);
		};
	};
	var getBellFunc = { | nn, freq |
		{ | vel|
			var synths;
			var row = nn.asString[0].digit;
			if(toggleGroups[nn].isNil) {
				toggleGroups[nn] = Group(s);
				synths = toggleGroups[nn];
			};
			synths = toggleGroups[nn];
			Synth(\sinFmHit, [\freq, freq, \amp, 0.8 * vel, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)], synths);
			Synth(\sinFmHit, [\freq, freq * [-0.33, 0.33].choose.midiratio, \amp, 0.8 * vel, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)], synths);
			~enabledRows.add(row);
			togglePrevious.(row * 10 + 5, vel);
			~noteMap.colorAllPads;
			synths;
		}
	};
	var getBellReleaseFunc = { | freq |
		{ | vel |
			Synth(\sinFmHit, [\freq, freq, \amp, 0.8 * vel, \cmRatio, 3.5, \modIndex, 2.2, \release, 0.4, \pan, rrand(-1.0, 1)]);
			Synth(\sinFmHit, [\freq, freq * [-0.33, 0.33].choose.midiratio, \amp, 0.8 * vel, \cmRatio, 3.52, \modIndex, 2.2, \release, 0.4, \pan, rrand(-1.0, 1)]);
		}
	};
	~enabledRows = Set();
	m.hit(18, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(1);
		togglePrevious.(15, vel);
		~noteMap.colorAllPads;
	});
	m.hit(28, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(2);
		togglePrevious.(25, vel);
		~noteMap.colorAllPads;
	});
	m.hit(38, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(3);
		togglePrevious.(35, vel);
		~noteMap.colorAllPads;
	});
	m.hit(48, { | vel |
		Synth(\sinFmHit, [\freq, 800, \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(4);
		togglePrevious.(45, vel);
		~noteMap.colorAllPads;
	});
	m.hit(58, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(5);
		togglePrevious.(55, vel);
		~noteMap.colorAllPads;
	});
	m.hit(68, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(6);
		togglePrevious.(65, vel);
		~noteMap.colorAllPads;
	});
	m.toggle(71, { | vel |
		Synth(\sinPulse, [\freq, 50, \pan, rrand(-1.0, 1), \distortionFactor, 20]);
	});
	m.toggle(72, { | vel |
		Synth(\meoCircles, [\bufnum, ~samples.meo]);
	});
	m.hit(78, { | vel|
		Synth(\sinFmHit, [\freq, 800 * 3.75.midiratio, \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 3.75.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		~enabledRows.add(7);
		togglePrevious.(75, vel);
		~noteMap.colorAllPads;
	});
	m.toggle(81, { | vel | Synth(\sinFmHit, [\freq, 100, \amp, vel * 1.6, \cmRatio, 3.5, \modIndex, 0.5, \release, 10, \pan, rrand(-1.0, 1)]); });
	m.toggleOff(81, getBellReleaseFunc.(100));
	m.toggle(82, getBellFunc.(82, 150));
	m.toggleOff(82, getBellReleaseFunc.(150));
	m.toggle(83, getBellFunc.(83, 200));
	m.toggleOff(83, getBellReleaseFunc.(200));
	m.toggle(84, getBellFunc.(83, 200));
	m.toggleOff(84, getBellReleaseFunc.(200));
	m.toggle(87, getBellFunc.(87, 800 * 1.5.midiratio));
	m.toggleOff(87, getBellReleaseFunc.(800 * 1.5.midiratio));
	m.toggle(88, getBellFunc.(88, 800 * 3.75.midiratio));
	m.toggleOff(88, getBellReleaseFunc.(800 * 3.75.midiratio));

	// Column 5
	m.toggle(15, getCol5Func.(200));
	m.toggle(25, getCol5Func.(300));
	m.toggle(35, getCol5Func.(350));
	m.toggle(45, getCol5Func.(266));
	m.toggle(55, getCol5Func.(295));
	m.toggle(65, getCol5Func.(400));
	m.toggle(75, getCol5Func.(420));
	m.toggle(85, { | vel, current |
		var synth = getCol5Func.(490).(vel, current);
		synth;
	});

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
		if(nn % 10 == 5) {
			color = ~config.toggledPadColor;
		};
		if(~enabledRows.includes(nn.asString[0].digit)) {
			color = ~config.enabledRowColor;
		};
		color;
	});
	m.colorPadActive({ | nn |
		var color = rrand(0, 127);
		if(m.current.toggleMap[nn].notNil) {
			color = ~config.toggledPadColor;
		};
		color;
	});
	// Callback to reset this to opening
	m.onReset({
		~enabledRows = Set();
		toggleGroups.collect { | g |
			g.free;
		};
		toggleGroups = ();
	});
});