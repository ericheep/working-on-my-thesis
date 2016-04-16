// carousel.ck

OscOut out;
out.dest("127.0.0.1", 12001);

Hid key;
HidMsg msg;
int index, load;

["0-0-black.png", "0-1-verde-night.jpg", "0-2-blank.png",
 "1-0-animal-profile.jpg", "1-1-animal-verde.jpg", "1-2-sean-tamsen.jpg",
 "1-3-verde-rain.jpg", "1-4-scout.jpg", "1-5-animal-cnc.jpg", "1-6-animal-dedcat.jpg",
 "1-7-austin-happy.jpg", "1-8-animal-setup.jpg", "1-9-blank.png",
 "2-0-red-wall.jpg", "2-1-red-wide.jpg", "2-2-red.jpg", "2-3-red-trailer.jpg"] @=> string filenames[];

if (!key.openKeyboard(0)) me.exit();
<<< "Keyboard '" + key.name() + "' is working", "" >>>;

// sound stuff
SndBuf slides[7];
SndBuf slideNoise => dac;

for (int i; i < slides.size(); i++) {
    slides[i] => dac;
    me.dir() + "audio/slide-" + (i + 1) + ".wav" => slides[i].read;
    slides[i].pos(slides[i].samples());
}
me.dir() + "audio/slide-noise.wav" => slideNoise.read;

slideNoise.pos(slideNoise.samples());
450::ms => dur preload;

fun void keyboardInput() {
    while (true) {
        key => now;
        while (key.recv(msg)) {
            if (msg.isButtonDown()) {
                if (load) {
                    // forward
                    if (msg.ascii == 32) {
                        oscSendInt("/index", 0);

                        Math.random2(0, slides.size() - 1) => int which;
                        slides[which].pos(0);
                        slides[which].samples()::samp - preload => now;

                        (index + 1) % filenames.size() => index;
                        oscSendInt("/index", index);
                    }
                    // backward
                    if (msg.ascii == 66) {
                        oscSendInt("/index", 0);

                        Math.random2(0, slides.size() - 1) => int which;
                        slides[which].pos(0);
                        slides[which].samples()::samp - preload => now;

                        index--;
                        if (index < 1) {
                            filenames.size() - 1 => index;
                        };
                        oscSendInt("/index", index);
                    }
                }
                else if (msg.ascii == 32) {
                    // add rampUp
                    slideNoise.pos(0);
                    slideNoise.loop(1);
                    slideNoise.gain(0.0);

                    // load pictures
                    1 => load;

                    oscSendInt("/NUM_PHOTOS", filenames.size());
                    for (int i; i < filenames.size(); i++) {
                        oscSendIntString("/filename", i, filenames[i]);
                    }
                    for (float i; i < 1.0; i + 0.01 => i) {
                        slideNoise.rate(i);
                        slideNoise.gain(i);
                        0.01::second => now;
                    }
                }
            }
            if (msg.isButtonUp()) {

            }
        }
    }
}


fun void oscSendInt(string addr, int val) {
    out.start(addr);
    out.add(val);
    out.send();
}

fun void oscSendIntString(string addr, int val1, string val2) {
    out.start(addr);
    out.add(val1);
    out.add(val2);
    out.send();
}

spork ~ keyboardInput();

while (true) {
    1::ms => now;
}
