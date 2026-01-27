# Obtaining and Analyzing CSI Information

Follow the instructions provided at https://dhalperi.github.io/linux-80211n-csitool/installation.html to install the data logging tool, and use its MATLAB functions to acquire channel state information (CSI). We record the collected data into a file named `csi.dat`. A sample MATLAB script for reading and analyzing the data is shown below:

~~~matlab
csi_trace = read_bf_file('csi.dat');
csi_entry = csi_trace{4};
csi = get_scaled_csi(csi_entry);
% CSI is an Ntx × Nrx × 30 matrix, representing the channel information across 
% Ntx transmit antennas, Nrx receive antennas, and 30 subcarriers.
figure
plot(db(abs(squeeze(csi(1,:,:)).')))
hold on
plot(db(abs(squeeze(csi(2,:,:)).')))
legend('RX Antenna A', 'RX Antenna B','TX Antenna A', 'TX Antenna B', 'Location', 'SouthEast' );
xlabel('Subcarrier index');
ylabel('SNR [dB]');
~~~

<center>
<img src="./fig/csidata.jpg" width=600px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9; display: inline-block;color: #999;padding: 2px;">Figure. SNR values derived from CSI data</div>
</center>

The figure above illustrates the SNR results converted from CSI data acquired using a 2×2 (nTx×nRx) antenna configuration. The horizontal axis represents the 30 distinct subcarriers, while the vertical axis shows the corresponding SNR values.

We have introduced fundamental methods for acquiring CSI. With these basic acquisition techniques, most CSI-based sensing tasks can already be carried out. Indeed, many related research papers build upon exactly such approaches. Subsequent work typically focuses on processing and applying the CSI data—for example, employing machine learning for classification, denoising CSI measurements, or separating multipath components.

Numerous tools exist for CSI acquisition and analysis. In the previous section, we also provided relevant reference links for further exploration. However, the most critical aspect lies in how to effectively apply CSI data. Furthermore, it is essential to carefully consider the limitations of CSI data. Although numerous sensing applications based on CSI have been proposed, we recommend that, after acquiring CSI data, you revisit the conceptual discussion of CSI presented earlier in the communications section, reflect critically on its inherent limitations, and then proceed with application development accordingly.