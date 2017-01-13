# Space Squid - A Sound-Responsive Smartphone-Controlled LED Installation

This project was a rapid-assembly of easily accessible parts, both physical and code, to produce a lighting element for a visual arts space at Astral Harvest Music & Arts Festival in northern Alberta, Canada, designed to complement a new structure. The structure was large, tent-like in shape with a high-vaulted peak and comprised of a combination of aluminum composite panels (its shell) and natural timbers (its supports). The height inside the structure lent itself towards a chandelier element, and the Space Squid was conceived as a similar combination of organic and technological to the structure, following an outer-space theme of the festival.

The Space Squid consisted of a 1m diameter by 40cm tall clam-shell body made out of thermoplastic formed overtop of a dome-shaped fire pit lid, with eight 5m length tentacles made of ridged white plastic tubing. Each of the top and bottom shells contained 100 clear-lensed through-hole mounted WS2812B LEDs arranged in a starburst pattern (aiming for a UFO-like distribution), to provide directional light that would dance on the structure's ceiling and display a brightly pulsing core to the installation. The tentacles each contained 50 WS2812B LEDs at 10cm spacing, and were attached to the ceiling and supports of the structure to give the illusion of an alien creature grabbing hold to support itself, with saturated shifting colours dancing along their twisting lengths. Inside the clamshell was a support plastic disc holding everything together and serving as a mounting point for the electrical components, the Raspberry Pi and the FadeCandy controllers.

This structure was adjacent to a stage, and so the music from the stage was used as an input, listening from a USB microphone. This had a side-effect of making the structure responsive to ambient sounds and voices, and so the Space Squid would continue to gently pulse during the times when the stage was shut down, moreso if there were nearby artists or passers-by having conversations.

It would have been very difficult to correctly pre-calibrate the responsiveness of the installation to the stage, so I assembled a quick OSC multi-touch slider interface using NexusUI to allow adjustment of the Processing sketch's parameters in the field. To provide network connectivity, the Pi 3's onboard Wi-Fi was configured to be a wireless access point. I then connected to the Squid's internal Wi-Fi with my smartphone, opened a page delivered from its web server, and had a workable means of smoothly field-calibrating and providing some variety of effect night-to-night.

The Processing sketch was derived (quite directly) from FFT examples provided in the fadecandy-master repo, with some modifications to add OSC hooks for its key parameters and a few minor customizations.

The project timeline was three weeks from concept to installation.

To do: Add Wi-Fi configuration, pictures & video, and a whole lot of code cleanup.

## Description of important pieces

www/squidcontrol/index.html - NexusUI JS control panel with sliders for important variables, which makes AJAX calls to nexusOSCRelay.php whenever a widget changes.

www/squidcontrol/lib/nexusOSCRelay.php - Receives AJAX calls from above, forwards on widget data as OSC to squidprime.pde.

squidprime/squidprime.pde - Receives OSC calls via OscP5, listens and analyzes with Minim, produces visual effects. Based very closely on [this example](https://github.com/scanlime/fadecandy/tree/master/examples/processing/grid32x16z_particle_fft_input) from the FadeCandy Processing examples.

squidprime/data/colors.*.png - Some alternate gradients/swatches for varying the colour scheme.

## Resources

**[FadeCandy](https://github.com/scanlime/fadecandy)**: I found this WS2812B LED controller, its libraries and its server to be particularly easy to use. It's built on the Open Pixel Control protocol, so anything else that produces OPC would be able to use the FadeCandy. , and the [other Processing examples](https://github.com/scanlime/fadecandy/tree/master/examples/processing) are really useful. These sketches can be used with other OPC-compatible controllers, or with [Open Lighting Architecture](https://www.openlighting.org/ola/) for a much wider range of controllers.

**[NexusUI](https://github.com/lsu-emdm/nexusUI/)**: Originally I was using OSC iPhone apps, but this approach wound up being more flexible and universal across multiple devices. In case the artists found the installation distracting, I gave them instructions for how to access to control panel from their phones so they could turn it down, change the balance, etc.. The [nx-AjaxDemo](https://github.com/lsu-emdm/nx-AjaxDemo) provides the PHP OSC handler for the front-end JavaScript UI, and has a lot of useful examples (though with an earlier version of the UI).

**[Running Processing headless on a Raspberry Pi](https://nocduro.ca/2016/01/06/running-an-exported-processing-3-sketch-on-a-headless-raspberry-pi/)**: solves many of the inherent "gotchas" with running Processing on Linux without an attached display, without requiring Processing (using compiled Java applications), allowing everything to work via CLI over SSH. The comments include updates for Raspbian Jesse.

**[Using VNC on the Pi](https://www.realvnc.com/docs/raspberry-pi.html)**: The other headless route is to actually use a GUI, run Processing 3.0+ and play your sketch within that application. You then connect via a VNC client from a laptop or smartphone to get things running. When I tried this route, I found RealVNC from my phone as a reliable-enough client.

**[Using a Pi 3 as a Wireless Access Point](https://frillip.com/using-your-raspberry-pi-3-as-a-wifi-access-point-with-hostapd/)**: I used my own self-contained Wi-Fi network to eliminate reliance on spotty Wi-Fi on site. I was able to fully test everything from home, so all I needed on arrival was power.

**[LEDs from Shenzhen Rita Lighting Ltd](https://www.aliexpress.com/item/Addressable-DC5V-WS2812B-IP68-pixel-node-epoxy-resin-filled-50pcs-a-string-transparent-cover/32366638195.html)**: I wanted something waterproofed and pre-wired (to save a lot of soldering time) in lengths the FadeCandy can use (=<64 LEDs). The throughhole mount was useful for the clamshell, and the 10cm spacing made the illusion of glowing suckers in the tentacles. The IP68 waterproofing was handy, as the site was quite humid, had prolonged rainstorms and the structure was not perfectly water-tight. I used both the clear (for the clamshell) and diffused (for the tentacles) options.



