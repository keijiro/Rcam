Rcam
====

![gif](https://i.imgur.com/ihhQwGw.gif)
![gif](https://i.imgur.com/IsKzGCQ.gif)
![gif](https://i.imgur.com/cXx6JJH.gif)
![gif](https://i.imgur.com/tGuupN4.gif)

[Vimeo - Compilation of social media video posts](https://vimeo.com/346711967)

Rcam is an experimental project that uses a real time volumetric video capture
system for live performance visuals.

Rcam consists of the following technologies:

- [Unity]
  - [Visual effect graph]
  - High definition render pipeline
- [Intel RealSense]
  - D415 depth camera
  - T265 tracker
- Backpack PC ([MECHREVO Vest PC II])
- [TouchOSC]
- [NewTek NDI]

[Unity]: https://unity3d.com
[Visual effect graph]: https://unity.com/visual-effect-graph
[Intel RealSense]: https://www.intelrealsense.com/
[MECHREVO Vest PC II]:
  http://www.mechrevo.com/en/html/VRshebei/Vest_PC/Vest_PC_I/2016/0708/94.html
[TouchOSC]: https://hexler.net/products/touchosc
[NewTek NDI]: https://www.newtek.com/ndi/

Volumetric data is captured in real time and visualized on the backpack PC
carried by the camera operator. Rendered frames are send to a projector via
ethernet link using NDI video transfer protocol.

This system was used in a live performance with [umio] at [Channel 20]. Here is
a [video compilation] of social media posts.

[Channel 20]: https://channel20.peatix.com/
[umio]: https://soundcloud.com/umi-o
[video compilation]: https://vimeo.com/346711967

System requirements
-------------------

- Unity 2019.1
- Desktop system with HDRP support
- RealSense D415 and T265
- TouchOSC

To control visuals, upload `Rcam.touchosc` to TouchOSC app using TouchOSC
Editor. Please note that Windows Defender Firewall has to be turned off to
receive OSC signals on a Windows system.

Also you can try the effects in the Editor by manually enabling visual effects
from the Inspector.

Frequently asked questions
--------------------------

#### How do I mount T265 on D415? It doesn't have a camera screw thread.

I designed a custom bracket for this purpose, which is available on [Tinkercad].

[Tinkercad]:
  https://www.tinkercad.com/things/0FBAyD8ACOJ-realsense-t265d4xx-bracket

#### Why T265 is required? Isn't D415 enough to capture depth?

If the camera is fixed at a single point, T265 tracker isn't needed. It's used
to capture the movement of the camera into the 3D scene. It also used to
compensate jitter caused by hand. In other words, it implements a software
motion stabilizer.

Special thanks
--------------

Special thanks to [@z_zabaglione] for lending me the backpack PC.

[@z_zabaglione]: https://twitter.com/z_zabaglione
