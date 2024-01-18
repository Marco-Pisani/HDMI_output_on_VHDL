# HDMI_output_on_VHDL
VHDL code for HDMI output on a Zybo z7-20

# story
It was an university project on VHDL that is part of something bigger that should also connect to the ARM cpu of the Zynq chip. I tried doing everything myself without using IPs in order to learn VHDL.

# specs
current resolution is 480x640 60 Hz

# references
Understanding the encoder module: https://www.cs.unc.edu/Research/stc/FAQs/Video/dvi_spec-V1_0.pdf


# explanation

toppest_lvl.vhd is the highr wrapper module of everything, it contains cpu, clock_gen and top_lvl:

![alt text]([http://url/to/img.png](https://github.com/Marco-Pisani/HDMI_output_on_VHDL/blob/main/cpu_test.png)https://github.com/Marco-Pisani/HDMI_output_on_VHDL/blob/main/cpu_test.png)

