# acarsgen &ndash; Octave/MatLab scripts for ACARS waveform generation

This repository contains Octave/MatLab scripts to generate Plain-Old-ACARS (PoA) waveform IQ files with arbitrary message payloads.

PoA is simply a Minimum Shift Keyed envelope wrapped into classic Amplitude Modulation for transmission with generic aviation voice radios. The MSK contains two symbols at 1200&nbsp;Hz and 2400&nbsp;Hz respectively, and so delivers 2400&nbsp;bps.

The AM wrapping is nothing to write home about, it's just classic double sideband AM with a modulation index of 100&nbsp;%.


# How to use?

Install GNU/Octave or MatLab.

Signal package is required. For Octave, run `pkg install -forge signal`.

In Octave or Matlab run `acarsgen`

The script asks to input only the message field of ACARS. A maximum of 220 character is allowed due to protocol limitations. If you want, you can edit the contents of _gen_acars_msg_aju1.m_ to change the other fields to fit your needs.

The script outputs a single file "poa_1M152.cs8" designed for transmission with **HackRF One** hardware. The file is interleaved signed int8 I and Q channels at a sampling rate of 1&nbsp;152&nbsp;000 Hz (or 24&times;48&nbsp;000 Hz). The signal is appended with zeroes to make the file exactly one second in length.

The scripts are interdependent in the following order: _gen_am_wrap_aju1.m_ &rarr; _gen_msk_aju1.m_ &rarr;  _gen_acars_msg_aju1.m_


# What for?

For SCIENCE!


# It's on you

Disruption of aviation communications will put you to jail. Be smart and do not test your luck.

If you'd like to try reception of your signals, I suggest looking into `acarsdec`.


# License

MIT license. Read more in LICENSE.md