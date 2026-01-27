# Case: Implementing a Recording and Playback Program

Let's look at a real example of sampling and quantization — this also marks the beginning of our entire data processing experiment. This experiment can be carried out directly on a smartphone, showing how sound sampling and quantization are performed on mobile devices.

Before conducting the experiment, you need to prepare a smartphone (either Android or iOS) and set up the basic development environment. If you're not yet familiar with this process, many online resources are available for reference.

The key code for recording audio is shown below. Pay close attention: although we use acoustic signals as an example to demonstrate the process of sampling and quantization, the underlying principles are fundamentally similar to those used in electromagnetic waves and other wireless communication systems.

```java
// Sampling rate: 48 kHz
int SamplingRate = 48000;
// Quantization bit depth: 16-bit
int audioEncoding = AudioFormat.ENCODING_PCM_16BIT;
// Number of channels: stereo (dual channel)
int channelConfiguration = AudioFormat.CHANNEL_IN_STEREO;

// ...other code...

public void StartRecord(String name) {
    // ...
    // File output stream
    OutputStream os = new FileOutputStream(file);
    BufferedOutputStream bos = new BufferedOutputStream(os);
    DataOutputStream dos = new DataOutputStream(bos);

    // Get the minimum buffer size required for AudioRecord under current sampling and channel settings
    bufferSize = AudioRecord.getMinBufferSize(SamplingRate, channelConfiguration, audioEncoding);
    // Create an AudioRecord instance; consider the meaning of each parameter
    AudioRecord audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, SamplingRate, channelConfiguration, audioEncoding, bufferSize);

    // Allocate a byte array to hold raw data read from the AudioRecord instance
    byte[] buffer = new byte[bufferSize];
    // Start the recording
    audioRecord.startRecording();

    // Set the recording flag to true
    isRecording = true;
    // Continuously read data from AudioRecord and write it into the output stream as long as isRecording is true
    // When the stop button is pressed, isRecording becomes false and the loop ends
    while (isRecording) {
        int bufferReadResult = audioRecord.read(buffer, 0, bufferSize);
        for (int i = 0; i < bufferReadResult; i++) {
            dos.write(buffer[i]);
        }
    }
    // Stop recording and close the output stream
    audioRecord.stop();
    dos.close();
    // ...
}
```

The above code represents the following process:

An ADC (Analog-to-Digital Converter) continuously converts analog sound signals into digital form (thus, the sampling and quantization processes are already completed by hardware — we don't need to handle this explicitly in software). The resulting digital signal is stored in a buffer, which we must periodically read from and save into a file in a specific audio format.

This process is analogous to network data handling. In networking, data first passes through a network interface card (NIC), whose key function is converting physical signals into digital data. Recall network programming practices (or imagine how network transmission works on a computer): we similarly need to extract received data from a buffer.

There are different strategies for handling data in such buffers:
1. **Polling**: repeatedly checking whether new data has arrived in the buffer.
2. **Interrupt-driven**: generating an interrupt when data arrives, signaling that processing should begin.
Both polling and interrupt methods support non-blocking operation, allowing users to proceed without waiting at that point. 
3. **Blocking mode**: the program waits until data is available in the buffer before continuing. 

Each method has its advantages and trade-offs, and choosing the appropriate one is a common challenge in communication systems and hardware interfacing. Delayed data processing may result in overwritten and lost data — a problem also encountered in network transmission.

Once data is successfully read from the buffer, we obtain sampled and quantized digital data — the only form computers can actually process. Note that the original analog sound cannot be preserved in its pure form.

Additionally, this section introduces several important concepts often overlooked in typical network learning, due to limited exposure to low-level signal processing. During recording setup, three key parameters must be configured:

- **Sampling rate**: currently set to $48 KHz$. (Revisit earlier sections to understand how this rate affects signal reconstruction, and you'll see why it's critical.) A sampling rate of $48 KHz$ is sufficient to perfectly reconstruct any original signal with frequencies below $24 KHz$, according to the Nyquist-Shannon sampling theorem. This rate captures both human speech and audible sound ranges. (Consider: what are the approximate frequency ranges of human hearing and speech?)

- **Quantization bit depth**: set here to 16 bits, meaning each sample is represented using 16 bits. (Think: how many discrete amplitude levels can this represent?)

- **Number of channels**: stereo (two channels), meaning two separate audio streams are recorded simultaneously.

Now, suppose we have an audio file — either recorded via code or programmatically generated — we can play it back on the phone. The core code for audio playback is as follows:

```java
public void StartPlay(String name) {
    // ...
    // File input stream
    InputStream is = new FileInputStream(file);
    // For WAV files, skip the 44-byte header; actual audio data starts afterward
    is.skip(44);
    // Determine the buffer size needed for AudioTrack under current settings
    int bufferSize = AudioTrack.getMinBufferSize(SamplingRate,
                channelConfiguration, audioEncoding);
    // Create an AudioTrack instance
    AudioTrack audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, SamplingRate, channelConfiguration, audioEncoding, bufferSize, AudioTrack.MODE_STREAM);
    // Buffer to hold audio data read from the file
    byte[] buffer = new byte[bufferSize];
    int readCount;
    while (is.available() > 0 && isPlaying) {
        // Read a chunk of audio data from the file
        readCount = is.read(buffer);
        if (readCount == AudioTrack.ERROR_INVALID_OPERATION || readCount == AudioTrack.ERROR_BAD_VALUE) {
            continue;
        }
        if (readCount > 0) {
            // If valid data was read, write it to AudioTrack for playback
            audioTrack.write(buffer, 0, readCount);
            audioTrack.play();
        }
    }
    // Stop playback and close the input stream
    is.close();
    audioTrack.stop();
    // ...
}
```

When playing back audio, we still need to specify parameters such as sampling rate, bit depth, and number of channels — and these must match those used during recording. Otherwise, the audio will not play correctly. (Think: why are these parameters necessary?) The entire process described here exists in standard wireless communication systems as well, though typically hidden from view. Through this hands-on example, we aim to build intuitive understanding of the initial steps — sampling and quantization — in communication systems.

> Consider and experiment: what happens if the audio was recorded at $48 KHz$ sampling rate but played back at $24 KHz$? Similarly, try combinations with different bit depths or channel configurations, and explain why the resulting sound differs from the original. Such experiments deepen your understanding of signal generation, transmission, and reception processes.