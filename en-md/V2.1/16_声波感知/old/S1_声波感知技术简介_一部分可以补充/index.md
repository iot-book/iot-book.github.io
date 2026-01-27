# Introduction to Acoustic Sensing Technology

## Technical Background

With the rapid proliferation of mobile devices, various Internet of Things (IoT) applications based on wireless sensing have emerged in recent years. Among these, acoustic sensing technology has attracted widespread attention from both academia and industry due to its high accuracy and low hardware requirements, and is expected to be increasingly applied in our daily production and life in the future.

Acoustic sensing offers irreplaceable advantages compared to other wireless sensing technologies. For example, in terms of location awareness, sound-based indoor positioning is a relatively straightforward approach capable of achieving high precision. As long as speakers and audio-recording smart devices are present in the environment, sound-based indoor positioning can be implemented—making it cost-effective. This technology can achieve millimeter-level positioning accuracy, giving it a significant advantage in terms of precision. The table below compares acoustic positioning with several other common indoor positioning technologies:

<center>
<img src="./fig/定位技术比较.png" width=600px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">Fig. Comparison of several indoor positioning technologies</div>
</center>

**1. Time-of-Flight Based Sensing Methods**

Early works on acoustic positioning and tracking were primarily based on Time of Arrival (TOA) or Time Difference of Arrival (TDOA). For instance, the work by K. Liu et al. [13][14] achieved indoor acoustic positioning with decimeter-level accuracy. Guoguo [15] is another high-precision indoor positioning system using acoustic signals, which employs a pre-deployed beacon transmitting modulated acoustic pulses. A smartphone calculates its distance from the beacon based on signal arrival time. BeepBeep [18] computes the distance between mobile phones by measuring the propagation time of sound signals. Each phone records the time difference between when a sound signal is transmitted and when it is received from another phone, thereby estimating inter-device distances. One key advantage of BeepBeep is that it does not require clock synchronization among devices—a common challenge in similar systems.

**2. Doppler Effect Based Sensing Methods**

In recent years, many systems have been developed for ranging and localization using the Doppler effect. The principle behind Doppler-based positioning and ranging is as follows. According to the Doppler effect, we can measure the velocity of a moving target. The velocity calculation formula is:

$$
v=\frac{F_c}{F}c
$$

<center>
<img src="./fig/多普勒原理.png" width=500px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">Fig. Principle of the Doppler effect</div>
</center>

Here, $F$ denotes the original signal frequency, $F_c$ represents the frequency shift caused by relative motion, $v$ is the speed of the moving target, and $c$ is the speed of sound in air. Since displacement equals the integral of velocity over time, integrating the calculated velocity allows us to determine the distance traveled by the target over a period. If the initial position of the target is known, its final position can be computed, enabling continuous tracking and localization.

To calculate the object's velocity, we must first obtain the frequency shift $F_c$ induced by relative motion. Typically, $F_c$ is obtained by applying the Short-Time Fourier Transform (STFT) to the received acoustic signal, resulting in a time-frequency representation. If the original signal has a fixed frequency, the frequency shift $F_c$ can be determined by computing the difference between the original frequency and the received frequency at a given moment. STFT is a Fourier transform method based on sliding windows: a window slides along the signal, and a Fourier transform is performed on the data within each window, yielding frequency-domain information—including frequency shifts—over successive time intervals.

Assuming the window length is $L_w$ and the sampling rate is $F_s$, the frequency resolution ΔF can be calculated as:

$$
D_F = \frac{F_s}{L_w}
$$

Given the original signal frequency $F$ and the speed of sound $c$, we can derive the velocity estimation accuracy achievable by Doppler-based tracking methods:

$$
D_v = \frac{D_F}{F}c
$$

Generally, shorter windows provide better time-domain resolution but poorer frequency-domain resolution, while longer windows offer improved frequency resolution at the expense of higher time delay and reduced temporal responsiveness.

**3. Phase-Based Sensing Methods**

During sound signal propagation, the phase of the source signal continuously changes. By extracting the phase difference between the received signal and the source signal, variations in the propagation path can be analyzed. LLAP [32] proposed a phase-based approach for ranging and localization. As an object moves, the phase of the reflected signal changes with the varying distance between the object and the sound source. Leveraging this principle, LLAP uses a single smartphone as both signal transmitter and receiver. It introduces an efficient algorithm to compute the phase of the reflected signal and estimate distance accordingly. With two microphones, LLAP enables 2D localization.

**Basic Scenarios in Acoustic Sensing**

In typical sound-based indoor positioning systems, loudspeakers serve as transmitters of acoustic signals, while microphones act as receivers. When both the transmitter and receiver reside on the same device and positioning relies on reflected signals from targets, the system is considered **device-free**. Conversely, if the transmitter or receiver is located on the target device itself, the system is classified as **device-based**.

Due to significant attenuation of sound signals upon reflection, device-free acoustic positioning often suffers from limited range. However, it offers advantages such as flexibility and ease of deployment. Despite differences in implementation, the underlying principles and techniques used in device-based and device-free acoustic positioning are fundamentally similar. The discussion of sound-based indoor positioning in this article primarily focuses on **device-based** approaches.

**Key Metrics for Acoustic Positioning**

- **Accuracy**: Accuracy is one of the most critical evaluation metrics in sound-based indoor positioning. Higher accuracy implies smaller positioning errors and better overall system performance.

- **Time Delay (Latency)**: Latency is another important metric. In real-time applications requiring prompt responses, lower latency improves user experience and conserves computational resources for other tasks.

- **Robustness**: Robustness is also essential in acoustic positioning systems. It typically refers to the system’s tolerance to different noise environments and its ability to maintain reliable performance under varying acoustic conditions.