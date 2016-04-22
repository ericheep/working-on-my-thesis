// carousel.ck

OscOut out;
out.dest("127.0.0.1", 12001);

Hid key;
HidMsg msg;
int index, load;

["0-black.png", "0-verde-night.jpg", "0-title-card.jpg", "0-blank.png",

 "1-animal-profile.jpg", "1-animal-verde.jpg", "1-sean-tamsen.jpg", "1-verde-rain.jpg", "1-scout.jpg", "1-animal-setup.jpg",
 "1-animal-dedcat.jpg", "1-austin-happy.jpg", "1-b-animal-dedcat.jpg", "1-austin-happy.jpg", "1-b-animal-dedcat.jpg", "1-verde-sky.jpg", "1-b-animal-dedcat.jpg", "1-austin-happy.jpg",
 "1-desk.jpg", "1-blank.png",

 "2-red-wall.jpg", "2-red-wide.jpg", "2-red-car-1.jpg", "2-red-trailer.jpg", "2-friends.jpg", "2-solenoid.jpg", "2-dead.jpg", "2-damage.jpg",
 "2-red-car-2.jpg", "2-truck.jpg", "2-bus.jpg", "2-verde-night.jpg", "2-train.jpg", "2-technology.jpg", "2-verde-cold-rain.jpg",
 "friends-1.jpg", "friends-2.jpg", "friends-3.jpg", "friends-4.jpg", "friends-5.jpg", "2-blank.png",

 "3-first-beast.jpg", "3-beast-performing.jpg", "3-austin-happy.jpg", "3-b-beast-performing.jpg", "3-second-beast.jpg", "3-amy.jpg", "3-b-second-beast.jpg",
 "3-bit.jpg",
 "3-b-second-beast.jpg", "3-third-beast.jpg", "3-fourth-beast.jpg",

 "couple-1.jpg", "couple-2.jpg", "couple-3.jpg", "couple-4.jpg", "3-blank.png",
 "4-amy.jpg", "4-dogs.jpg", "4-val-verde.jpg", "4-new-home.jpg", "4-new-years.jpg", "4-wulf.jpg", "4-outer.jpg", "4-mfa.jpg", "4-davy.jpg", "4-blank.png", "4-manu.jpg", "4-black.png"]
 @=> string filenames[];

if (!key.openKeyboard(0)) me.exit();
<<< "Keyboard '" + key.name() + "' is working", "" >>>;

// sound stuff
5 => int NUM_SLIDES;
SndBuf forward[5];
SndBuf backward[5];
SndBuf carouselNoise => ADSR env => dac;

adc => Gain gain => dac;

env.set(10::ms, 0::ms, 1.0, 10::ms);
env.keyOn();

for (int i; i < NUM_SLIDES; i++) {
    forward[i] => dac;
    backward[i] => dac;

    me.dir() + "audio/forward-" + (i + 1) + ".wav" => forward[i].read;
    me.dir() + "audio/backward-" + (i + 1) + ".wav" => backward[i].read;

    forward[i].pos(forward[i].samples());
    backward[i].pos(backward[i].samples());
}

me.dir() + "audio/carousel-noise.wav" => carouselNoise.read;

carouselNoise.pos(carouselNoise.samples());
dur preload;

fun void keyboardInput() {
    while (true) {
        key => now;
        while (key.recv(msg)) {
            if (msg.isButtonDown()) {
                if (load) {
                    // forward
                    if (msg.ascii == 32) {
                        1.0 => float speed;
                        int repeats;

                        (index + 1) % filenames.size() => index;

                        if (filenames[index].find("friends") == 0) {
                            5 => repeats;
                            0.55 => speed;
                        }
                        if (filenames[index].find("couple") == 0) {
                            4 => repeats;
                            0.55 => speed;
                        }

                        speed * 450::ms => preload;

                        oscSendInt("/index", 0);

                        Math.random2(0, forward.size() - 1) => int which;

                        env.keyOff();
                        if (filenames[index].charAt(2) == 98 && filenames[index].charAt(3) == 45) {
                            speed * backward[which].pos(0);
                            speed * backward[which].samples()::samp - preload => now;
                        }
                        else {
                            speed * forward[which].pos(0);
                            speed * forward[which].samples()::samp - preload => now;
                        }


                        oscSendInt("/index", index);

                        preload => now;
                        env.keyOn();

                        if (speed != 1.0) {
                            repeat(repeats) {
                                (index + 1) % filenames.size() => index;
                                oscSendInt("/index", 0);

                                Math.random2(0, forward.size() - 1) => int which;

                                env.keyOff();
                                if (filenames[index].charAt(2) == 98 && filenames[index].charAt(3) == 45) {
                                    speed * backward[which].pos(0);
                                    speed * backward[which].samples()::samp - preload => now;
                                }
                                else {
                                    speed * forward[which].pos(0);
                                    speed * forward[which].samples()::samp - preload => now;
                                }


                                oscSendInt("/index", index);

                                preload => now;
                                env.keyOn();
                            }
                        }
                    }
                    // backward
                    if (msg.ascii == 66) {

                        oscSendInt("/index", 0);

                        Math.random2(0, backward.size() - 1) => int which;

                        env.keyOff();
                        backward[which].pos(0);
                        backward[which].samples()::samp - preload => now;

                        index--;
                        if (index < 1) {
                            filenames.size() - 1 => index;
                        };
                        oscSendInt("/index", index);

                        preload => now;
                        env.keyOn();
                    }
                    if (msg.ascii == 79) {
                        oscSendInt("/off", 0);
                        for (1.0 => float i; i > 0.0; i - 0.01 => i) {
                            carouselNoise.rate(i);
                            carouselNoise.gain(i);
                            0.02::second => now;
                        }

                    }
                }
                else if (msg.ascii == 32) {
                    // add rampUp
                    carouselNoise.pos(0);
                    carouselNoise.loop(1);
                    carouselNoise.gain(0.0);

                    // load pictures
                    1 => load;

                    oscSendInt("/NUM_PHOTOS", filenames.size());
                    for (int i; i < filenames.size(); i++) {
                        oscSendIntString("/filename", i, filenames[i]);
                    }
                    for (float i; i < 1.0; i + 0.01 => i) {
                        carouselNoise.rate(i);
                        carouselNoise.gain(i);
                        0.02::second => now;
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
