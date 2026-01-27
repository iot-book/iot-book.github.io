# Wi-Fi Fingerprinting Localization ?? Should WiFi BFI be included as a section?

In [Chapter 13 "Wireless Localization"](https://iot-book.github.io/13_无线定位/S4_信号指纹定位算法/), we have already introduced the fundamental concept of fingerprint-based localization.  
Below, we discuss how Wi-Fi fingerprinting can be utilized for localization. Wi-Fi fingerprints typically include two of the most commonly used signal characteristics: multipath features of wireless signals and Received Signal Strength (RSS).

As electromagnetic waves propagate through space, they can reflect off smooth surfaces (such as walls or floors in buildings), diffract at sharp edges, and scatter when encountering small objects (like leaves). Signals transmitted from a source can reach the same location via multiple paths, resulting in the superposition of multiple signal copies at the receiver. Each propagation path has different energy levels and time delays. If the signal bandwidth is sufficiently large, individual multipath components can be resolved and processed at the receiver. The received signal strength also varies across different locations. The combination of multipath characteristics and RSS at a given location depends on the specific environment and is unique, making it suitable for use as a location fingerprint.

When a mobile device can receive signals from multiple transmitters, or when multiple fixed base stations can detect the same mobile device, we can construct an RSS vector using RSS measurements from multiple access points (APs) or receivers. This vector serves as a location-associated fingerprint—this is the typical Wi-Fi positioning fingerprint. Most Wi-Fi network interface cards can measure RSS from multiple APs (often sequentially). In many indoor environments today, mobile devices frequently detect signals from several APs, making the use of multi-AP RSS vectors meaningful for fingerprinting.

<center>
<img src="./fig/RSS定位示意.jpg" width=600px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">Figure. Illustration of RSS-based Localization</div>
</center> 

In Wi-Fi networks, APs periodically transmit beacon frames containing network information, Service Set Identifier (SSID, i.e., the name of the wireless network), supported data rates, and other system parameters. Beacon frames are one of many control frames used in Wi-Fi and are typically transmitted approximately every 100 ms. RSS measurements are usually derived from these beacon frames.  
Beacon frames are unencrypted, meaning they can still be used for localization even if the network is closed (i.e., the mobile device is not connected). Although beacon transmissions are nearly periodic, they are not strictly so—transmissions are delayed if the medium is busy and sent immediately once the channel becomes free, with the next transmission still scheduled at the original 100 ms interval, even if less than 100 ms has elapsed since the last transmission. Furthermore, if an AP operates across multiple channels, the mobile device must spend time scanning each channel before RSS measurement to avoid interference.

[TODO add more content]

We previously proposed a very simple and practical method for distinguishing users via fingerprinting [1]. There are also many more sophisticated approaches, such as CSI-based fingerprinting methods. However, their core ideas were covered in the wireless localization section, so we will not elaborate further here.

## References
1. [Linsong Cheng, Jiliang Wang: How can I guard my AP?: non-intrusive user identification for mobile devices using WiFi signals. MobiHoc 2016: 91-100](http://tns.thss.tsinghua.edu.cn/~jiliang/publications/MOBIHOC2016-NiFi.pdf)