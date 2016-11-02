r = audiorecorder(44100, 16, 1);
asdf = audiorecorder(44100, 16, 1);

record(r); % speak into microphone...
pause(r);
p = play(r); % listen


record(asdf); % speak into microphone...
pause (asdf)
z = play(asdf); % listen