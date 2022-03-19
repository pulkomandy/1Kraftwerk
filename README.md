1Kraftwerk
==========

How much Kraftwerk can you fit in a kilobyte? Let's find out!

1K intro for Amstrad CPC

Planned for Forever 2020 "other 8bit" competition, but that didn't happen.
I wanted to finish and polish it a bit during the trip to the party and during the party itself.
So you get something not as good as it could have been, I guess. I hope that's ok.

Code by PulkoMandy
Visuals and Music from Kraftwerk, adjusted to fit the constraints



Some random notes from 2020
---------------------------

Two years ago I released my previous 1K intro, 1Kusai. It used the CPC firmware
floating point routines to compute Bézier curves and render a picture.
Originally I wanted to add some music, but I ran out of time to squeeze that in.
I kept the idea of better music in 1K intros in my head, however.

This year the theme for Forever is "Robots" and the Kraftwerk song sounds like
a good match. So let's do something with it?

I started with some visuals to have a rough idea of the size budget for the
music. I took a picture of some live Kraftwerk concert and traced out some
outlines. This time I used only straight lines, so the code to draw the things
was a lot simpler and smaller. After a first session of work I had the thing
rendering, already under the 1K limit and with several ideas to further
optimize it (more on that later if I try them).

I also drafted the music in Arkos Tracker, even if it was clear that none of
the players provided with it would be suitable (they are designed, at best, for
4K intros, and I'm not doing one of these). Arkos Tracker players are of course
quite well optimized, so what could be the plan for a more compact one? The
answer, of course, once again lies in the CPC firmware (which I'm already using
for drawing lines and filling shapes).

The CPC BASIC has commands to manage sound (mainly SOUND, ENV and ENT). These
allow to define volume and tone "enveloppes" (variations over time) and
synchronize the 3 sound channels together. This lays the base for a music
player: notes, instruments, and timing. The only thing that remains is some
kind of "pattern" handler to feed the data to the firmware. I made something
very simple, each channel has a single pattern with a loop point (which allows
for some progressive buildup of the music, and then play the main part in a
loop). For now, I didn't need something like patterns.

The data for the music is not super efficient (9 bytes per note), but it is
very repetitive so it packs quite well. The firmware routines are not perfect,
but with some creativity, the limitations can be used at our advantage. For
example, the volume enveloppe can add and subtract arbitrary values to the
volume, but it does not clamp it to the range the AY can handle. This means
if you're not careful, it will rollover, and what you wanted to be silent will
now be maximum volume. But using that cleverly makes for a cheap way to repeat
a note multiple times.

Size stats (approximate, as the code changed a little after the music turned out even smaller)
----------------------------------------------------------------------------------------------

Amstrad standard binary file header: 128 bytes
ZX7 packer code: 89 bytes
Space remaining for packed data and code: 896 bytes
Space used by shapes and shape drawing code: 725 compressed bytes
Space left for music after this: 171 bytes

Possible optimizations
----------------------

- Use relative lines instead of absolute. Allows to use 1byte instead of 2 for
  each coordinate, and repetitive shapes (eg. the consoles) will pack a lot
  better because most of the lines will be identical. However, hiding control
  bits in the MSB will not work as there will not be enough space. The least
  significant bit can be used because the firmware works in a 640x400 space
  and scales down to 320x200 when drawing, so adding or removing 1px from a
  coordinate will not have any visible effect. Alternatively, an escape value
  (0x80?) can be used instead, and that may even end up being smaller because
  the code to extract and mask the control bits is not that simple, after all.
  This could save about 200 (!) bytes here, but the code has to be a little
  more complex (but probably not 200-byte complex).
- It would also be possible to keep absolute coordinates but have them remain
  < 256 bytes by setting an ORIGIN for each polygon and then using absolute
  commands. This way we can do away with the negative coordinates, which
  keeps the code simpler.

- Use rendez-vous in the music instead of adding silent notes. Rendez-vous costs
just one byte, so if it can save a 9 byte note entry, that's quite great.

- Think about how to factorize the music player code, repeating the same code
  3 times for each channel isn't great.

Lessons learned
---------------

Very repetitive data compresses much better than z80 code. Don't hesitate to
have the same sequence of bytes repeated multiple times if that makes your
z80 code even slightly smaller. This will compress very well.

I have a good toolchain for converting vector graphics from SVG (not perfect,
it still needs some handtweaking, for example for determining a good start
point for the fill). I don't have anything for the music, however. Should
probably think about it, because hand-converting it to assembler is not that
fun.

NEVER edit the generated data for SVG files by hand. It may seem easier at first,
but simplifying the source data allows to re-run the conversion pipeline when
you want to make a change in the encoding format.

The ZX7 compressor seems not very efficient at first, but it starts to perform
better when getting closer to the 1K limit. So filling the first bytes goes
fast, but filling the last remaining bytes fortunately goes a bit slower.
