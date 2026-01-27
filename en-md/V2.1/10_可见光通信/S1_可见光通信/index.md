# Visible Light Communication (VLC)

With the proliferation of IoT devices, an increasing number of devices are equipped with light-sensing capabilities—such as photodiodes, ambient light sensors, or cameras. While fulfilling their primary sensing functions, these components can also serve as communication interfaces.

Using light for communication is not a new concept; optical fiber communication has been widely deployed for decades. In the context of IoT, visible light communication (VLC) primarily refers to leveraging commonly available visible-light sensing devices (e.g., sensors and cameras) and light-emitting devices (e.g., displays and LED light sources) on IoT devices to achieve data transmission. Consider QR code scanning: a typical VLC scenario where a smartphone camera captures a QR code and decodes the embedded information to enable data exchange between two devices. A key advantage of this VLC approach is that no prior connection establishment is required between the communicating parties—and the connection process is fully transparent and directly controllable by the user. This explains the widespread adoption of QR codes today. Building upon this idea, numerous research efforts now explore high-efficiency data transmission between devices using displays and cameras.

Another prominent VLC concept is Li-Fi (Light Fidelity)—a method of data transmission using visible light. The term parallels Wi-Fi, substituting “Wi” (for *wireless*) with “Li” (for *light*). For instance, LED light sources can be used for data transmission: because LEDs support high-speed modulation, they can encode information in imperceptibly rapid on/off flickering patterns—e.g., “on” representing bit 1 and “off” representing bit 0. Photodetectors or mobile devices can decode such signals, and even transmit responses back to ceiling-mounted optical transceivers. This capability enables LED lighting fixtures to simultaneously provide illumination and serve as high-speed, ubiquitous VLC access points.

<center>
<img src="./images/8.png" width=600px>
</center>
<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">Fig. Li-Fi Application Concept</div>
</center>
<!-- Fig. 9 Li-Fi Application Concept -->

Compared with conventional Wi-Fi technology, Li-Fi exhibits distinct characteristics.  
Human living and working environments are pervasively illuminated. By exploiting this omnipresent illumination infrastructure for data transmission, users can enjoy ubiquitous network connectivity. Embedding a miniature chip into an LED bulb transforms it into a Wi-Fi-like access point, enabling any terminal device within its illuminated area to connect to the network at any time. If all light bulbs worldwide were upgraded to Li-Fi access points, streetlights themselves could become Internet gateways.

Li-Fi was not conceived to replace Wi-Fi, but rather to complement it—particularly in radio-frequency (RF)-sensitive environments such as aircraft cabins, mines, nuclear power plants, and medical facilities housing electromagnetic-interference-sensitive equipment. During flight, passengers are prohibited from using mobile phones because their RF emissions may interfere with pilot–control-tower communications. In contrast, Li-Fi operates via visible light and poses no such interference risk. Retrofitting overhead LED reading lamps with Li-Fi functionality would allow both voice calls and Internet access onboard aircraft.

VLC also holds promise for intelligent transportation systems. At night, drivers’ visibility is limited, and delayed awareness of road conditions often leads to serious accidents. Leveraging streetlights and vehicle headlights—enabled by Li-Fi—it becomes feasible to establish vehicle-to-vehicle (V2V), vehicle-to-traffic-signal (V2I), and vehicle-to-streetlight (V2S) communications. Such real-time traffic information sharing enhances driver situational awareness, helps prevent collisions, and improves driving safety.

Li-Fi leverages visible light for communication and offers the following advantages:

- **Abundant spectrum resources**:  
  The visible light spectrum spans approximately 10,000 times the bandwidth of the RF spectrum. This vast spectral resource enables Li-Fi to achieve significantly higher data rates and improved network throughput.

- **Low cost**:  
  LED bulbs are far less expensive than dedicated Wi-Fi access points—and are indispensable in daily life. Their ubiquity eliminates the need for extensive additional infrastructure, resulting in low deployment and operational costs.

- **Enhanced security**:  
  Because visible light is easily blocked and cannot penetrate walls, Li-Fi signals can be physically confined to a defined space, providing inherent physical isolation and improved communication security.

- **No electromagnetic interference (EMI)**:  
  Many precision instruments are highly susceptible to EMI. Since Li-Fi uses optical carriers instead of radio waves, it avoids EMI constraints entirely—making it suitable for environments where RF wireless communication is impractical or prohibited.

However, as an emerging wireless communication technology, Li-Fi still faces several challenges requiring urgent resolution:

- **Susceptibility to blockage**:  
  VLC links are easily interrupted by occlusion, compromising link reliability.

- **Intermittent light source availability**:  
  Although electric lighting is ubiquitous in human environments, lights remain off when sufficient natural illumination is present—rendering communication impossible during daylight hours.

- **Mobility support**:  
  A single LED access point provides only limited coverage. As mobile terminals move, frequent handovers among Li-Fi access points may cause connection drops.

- **Ambient light interference**:  
  Environmental light sources (e.g., sunlight or incandescent lamps) may introduce noise and degrade VLC performance.

- **User-friendly uplink communication**:  
  Downlink transmission—from Li-Fi access point to terminal—is naturally realized via visible light. However, designing a user-friendly uplink mechanism—i.e., enabling terminals to communicate back to the access point without causing discomfort—is nontrivial.  
  Few users would tolerate having their eyes illuminated by a smartphone’s LED during routine usage.

As a cutting-edge technology, Li-Fi’s ubiquity and abundant spectrum resources afford it broad developmental potential. Yet, as a nascent wireless communication paradigm, it remains in its early stages. Further research is essential to mature the underlying technologies and deliver robust, commercially viable products—ultimately enabling more comfortable, convenient, and intelligent lifestyles.