# Frequency Modulation

​		Frequency modulation, commonly referred to as Frequency-Shift Keying (FSK), uses different frequencies or combinations of frequencies to modulate different data.

​		The simplest form of frequency modulation can be represented similarly to On-Off Keying (OOK) in the frequency domain: a signal with a fixed frequency $f\not=0$ represents "1", and a signal with frequency $f=0$ represents "0".

​		Clearly, multiple distinct frequencies $F=\{f_0,f_1,f_2,....f_n\}$ can be used to represent different data values. When implementing this method, it is important to ensure that the differences between frequencies are sufficiently large; otherwise, closely spaced frequencies may be difficult to distinguish.

> Thought: What issues might cause closely spaced frequencies to be poorly distinguishable?

​		As previously analyzed and demonstrated, discrete Fourier analysis has inherent precision limitations. If frequencies are too close together, they may fall within the same frequency bin or adjacent bins, making them hard to differentiate.

​		Using combinations of different frequencies for modulation can significantly improve coding efficiency. When using six distinct frequencies for single-frequency modulation, only seven symbols can be generated at most: one symbol per frequency, plus one symbol representing a blank (no signal).

| Frequency | $f_1$ | $f_2$ | $f_3$ | $f_4$ | $f_5$ | $f_6$ | Blank |
|------------|-------------|------------|------------|-------------|------------|------------|------------|
| Symbol     | $f_1$  | $f_2$| $f_3$| $f_4$ | $f_5$| $f_6$| Blank |

​		With the same six distinct frequencies, if two-frequency combinations are used for modulation, $C_6^2+1=15+1 = 16$ symbols can be generated (15 frequency pairs plus one blank signal symbol).

| Frequency | $f_2$ | $f_3$ | $f_4$ | $f_5$ | $f_6$ | Blank |
|-----------|-------------|-------------|-------------|-------------|-------------|--------|
| $f_1$ | $f_1,f_2$ | $f_1,f_3$ | $f_1,f_4$ | $f_1,f_5$ | $f_1,f_6$ | - |
| $f_2$ | - | $f_2,f_3$ | $f_2,f_4$ | $f_2,f_5$ | $f_2,f_6$ | - |
| $f_3$ | - | - | $f_3,f_4$ | $f_3,f_5$ | $f_3,f_6$ | - |
| $f_4$ | - | - | - | $f_4,f_5$ | $f_4,f_6$ | - |
| $f_5$ | - | - | - | - | $f_5,f_6$ | - |
| Blank     | - | - | - | - | - | Blank |

> Thought: With such encoding, how would you decode the received data?

​		Certainly, even when using this approach, the coding efficiency remains quite low. In practical applications, such direct methods are rarely used for encoding and data transmission. However, it's useful to remember that, theoretically, such methods are feasible for data encoding and transmission.