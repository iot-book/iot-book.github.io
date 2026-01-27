# Preface to the Second Edition

This material was developed as my lecture preparation for the Internet of Things (IoT) course taught at Tsinghua University. Since this course targets upper-level undergraduate students—many of whom already possess foundational knowledge in computer science, rather than freshmen undergoing introductory studies—I observed during instruction that although students are exposed to numerous IoT concepts, they have limited hands-on experience. Their understanding of how actual IoT systems are implemented—and of the underlying principles—is often superficial.

Recalling my own early research in the IoT domain, I remember having access to even fewer open-source implementations; in many cases, hardware platforms were unavailable, and much of the infrastructure had to be built from scratch. This process involved numerous detours and pitfalls. Motivated by these experiences, I compiled this material while preparing for the course, making it publicly available to support students’ hands-on learning alongside classroom instruction.

This material focuses primarily on IoT communication and sensing, covering both core theoretical principles and practical implementation demonstrations. Its most distinctive feature is that each section includes executable code: some illustrate fundamental IoT communication and sensing principles; others implement algorithms from our own published papers; and still others reproduce implementations from cutting-edge IoT research. We hope this material serves learners at different stages effectively.

My research group’s primary focus lies in IoT communication and sensing. Over the years, we have designed and deployed several real-world systems, including:  
- The world’s largest outdoor multi-hop ad hoc sensor network at the time;  
- Low-power transmission protocols;  
- Low-power wide-area networks (LPWANs);  
- Passive LPWANs;  
- Sensing techniques leveraging ubiquitous IoT signals—including radio waves, acoustic waves, and visible light.  

We aim to share insights gained through these efforts.

The material is organized as follows:

1. Fundamental Concepts of IoT  
2. IoT Communication  
3. IoT Sensing  
4. IoT System Implementation  

Each section comprises both theoretical explanations and corresponding code implementations. These range from elementary signal-processing concepts—such as the Fast Fourier Transform (FFT) and filtering—to sophisticated implementations drawn from our own publications and other state-of-the-art research.

During preparation, we deliberately omitted topics widely covered in standard textbooks, as well as areas outside our expertise—thus avoiding unnecessary breadth at the expense of depth.

This material is suitable for the following use cases:

1. **Beginners entering the IoT field**: This material serves as an accessible entry point to core technical concepts. Reading it also helps prepare students to understand frontier research papers—many of which are directly implemented herein. I assign this material as pre-admission reading for prospective members of my research group, enabling them to gain a foundational overview before joining and thereby facilitating informed decisions about their research direction.

2. **Active IoT researchers**: The material includes implementations of foundational techniques from recent advances, serving as a practical reference for technical implementation.

3. **Course adoption**: It can function either as a primary textbook for courses on IoT communication and sensing—or as a complementary resource alongside other standard texts. The material contains numerous conceptual questions and end-of-chapter exercises, suitable for assigning as coursework. Accompanying lecture slides are under active development and will be distributed as soon as finalized.

4. **Laboratory instruction**: It supports the design and deployment of hands-on laboratory experiments. Overall, the material strives to be accessible to computer science students without prior communications background, while simultaneously serving as a valuable supplementary resource and lab companion for students in communications or related disciplines.

Given the scope and complexity of IoT, this material inevitably reflects the limits of my personal understanding and cannot comprehensively cover all subfields. Rather than attempting exhaustive coverage, our goal has been to emphasize key ideas and representative techniques. We warmly welcome feedback—including corrections, questions, and suggestions—during your use of this material.

If possible, please share your valuable comments and suggestions via email to: **jiliangwang@tsinghua.edu.cn**.

<!-- <center>
<img src="./iot-book交流讨论群聊二维码.png" width=300px>
</center> -->

This material represents a synthesis of our group’s accumulated experience in IoT research. We gratefully acknowledge every member of our team, especially Shuai Tong, Zhipeng Song, Zhenqiang Xu, Jing Yang, Boshun Dong, Qian Chen, Yijie Chen, Jiarui Zhang, Jinyan Jiang, and Junren Jiao, whose substantial contributions were instrumental in preparing this material.

Jiliang Wang  
December 2020  

@copyright Jiliang Wang  
No part of this material may be reproduced or used elsewhere without explicit written permission.