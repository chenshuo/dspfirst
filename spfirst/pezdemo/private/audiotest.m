% audio test

r = com.mathworks.toolbox.audio.JavaAudioRecorder(44100,16,1);
r.record;



r.stop;
signal = getaudiodata(r);

p = com.mathworks.toolbox.audio.JavaAudioPlayer(signal,44100,16);
p.play;

p.play;