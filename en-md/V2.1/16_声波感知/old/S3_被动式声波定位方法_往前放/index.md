# Passive Acoustic Source Localization Methods

## Research Background and Significance

With the continuous expansion of applications for Location-Based Services (LBS), indoor positioning systems are rapidly emerging as a new frontier in location technology research. These technologies hold broad application prospects in smart homes, security monitoring, and navigation tracking. Meanwhile, LBS and indoor positioning systems are increasingly being supported by embedded and Internet of Things (IoT) devices, offering greater convenience to everyday life.

There are various methods for acquiring location information. Traditional approaches include using GPS to obtain three-dimensional coordinates; however, these methods perform poorly in terms of accuracy in indoor environments. In recent years, researchers have begun exploring the indoor localization capabilities of novel wireless signals. By leveraging such signals, an increasing number of techniques have been developed to determine the precise indoor positions of people or objects. These include WiFi-based signal time-of-flight measurements [1], localization via WiFi signal reflections off the human body [2], object localization using RFID tags [3], and millimeter-wave reflection-based localization for multiple individuals [4].

In addition, traditional acoustic signal-based positioning systems have also attracted attention. Compared to the aforementioned radio frequency (RF) signals, acoustic systems typically require only microphones or speakers, resulting in significantly lower deployment costs than RF signal processing systems. Generally, acoustic-based positioning systems fall into two categories: active localization and passive localization. Active acoustic localization usually involves speakers emitting modulated sound signals within the system, with microphones capturing the reflected signals from objects. After a series of signal processing steps, the object's position is determined. In contrast, passive acoustic source localization relies solely on distributed microphone arrays receiving signals directly emitted by the sound source, followed by feature extraction and model-based processing to estimate the source’s position.

## Acoustic Source Localization Methods

This paper focuses on passive acoustic source localization in indoor environments. Passive source localization typically relies on distributed microphone nodes or microphone arrays. Passive localization methods can be broadly classified into two categories: (1) two-step localization based on signal feature extraction and parameter estimation, and (2) direct localization using raw signals.

**Two-Step Localization Methods**

The two-step method consists of two stages: feature extraction and geometric model solving.

In the first stage, the microphone array performs feature extraction from the received acoustic signals. Extracted features may include Time Difference of Arrival (TDoA), Gain Ratios of Arrival (GRoA), among others. Common techniques for extracting these features include cross-correlation algorithms for time delay estimation.

In the second stage, the extracted features are used to compute distances or distance differences between the source and each microphone. A spatial geometric model is established, transforming these parameters into a system of nonlinear equations. Various methods can then be employed to solve this system and obtain the source location. These include non-iterative analytical methods, maximum likelihood estimation, least squares methods, and iterative approaches such as the Taylor-series approximation and approximate maximum likelihood methods.

**Direct Localization Methods**

This category primarily includes beamforming algorithms based on maximizing output power, with Steered-Response Power (SRP) being a representative example. This method uses a delay-and-sum beamformer to enhance signals originating from specific spatial locations and measures the signal strength at each point. The algorithm then exhaustively searches over the entire space, performing beamforming calculations at every candidate location to construct a spatial power spectrum. The source location is identified as the position corresponding to the maximum output power. Alternatively, high-resolution spatial spectral estimation algorithms such as Multiple Signal Classification (MUSIC) can be used to estimate the direction of arrival of signals.

**Challenges in Passive Acoustic Source Localization**

From the perspective of localization accuracy:  
For two-step methods, literature [5] indicates that energy-based methods (e.g., GRoA) do not require perfectly synchronized clocks across microphone nodes—unlike TDoA or DoA-based methods. However, because they rely on averaged signal values rather than direct signal features, their accuracy is generally inferior to TDoA- or DoA-based approaches. Moreover, in centralized microphone arrays, the energy differences of received acoustic signals are often too small to enable effective localization using such energy-based methods. Both two-step and direct methods benefit from finer spatial search granularity, but direct methods tend to achieve smaller localization errors under such conditions.

Regarding robustness against noise and capability to handle multiple sources:  
Compared to direct methods, two-step methods are more sensitive to noise, as the initial feature extraction stage captures only partial summary information of the original signal, failing to fully exploit its richness. Traditional two-step methods cannot handle multiple simultaneous sound sources, whereas direct methods can identify multiple potential sources by detecting multiple peaks in the spatial power spectrum.

From the standpoint of computational complexity:  
Direct localization methods require beamforming computations at numerous spatial points, involving extensive delay-and-sum operations. In contrast, two-step methods typically involve only a single feature extraction step, with the subsequent geometric solving process imposing relatively low computational overhead. Consequently, achieving higher accuracy with traditional methods demands substantial computational resources, making real-time implementation challenging on standard IoT devices.