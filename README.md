# LibreMonitor
##Monitor your Freestyle Libre.

LibreMonitor is a little DIY device that uses near field communication to read data from a Freestyle Libre sensor and transmit it via bluetooth low energy to an iPhone application. LibreMonitor scans the sensor every two minutes. It transfers all the 32 history values for the last eight hours and the 16 trend values for the current time and the last 15 minutes and displays them in a chart and in a table. 

Be aware that only the so called raw data is used and you have to choose slope and intercept yourself to have the application calculate useful glucose values. Values that mostly work fine for my sensors are 0.13 for slope and -20 for offset. Any other internal information such as from the temperature sensors is not yet fully understood and thus neglected,

This code is published for the purpose that others can contribute and help to improve it or use it to improve their own devices.

LibreMonitor has no affiliation of any kind with Abbott. This is a DIY project for research purposes. The code provided here might provide wrong results. You will have to build your own device and are responsible for the results. Use at your own risk.  


##What you need to build a LibreMonitor

####Hardware

Parts needed for a LibreMonitor are

* [BM019 NFC-Module](http://www.solutions-cubed.com/bm019/) capable of ISO/IEC 15693 commands. Possible sources are [Solutions Cubed LLC](http://www.solutions-cubed.com/bm019/), [Warbutech](http://www.warburtech.co.uk/products/modules/solutions.cubed.bm019.serial.to.nfc.converter/) or 
[Robotshop](http://www.robotshop.com/eu/en/serial-to-nfc-converter-module.html).

* [Simblee](https://www.simblee.com) or [RFDuino](http://www.rfduino.com) and a corresponding USB Programming Shield. I recommend to get a startet kit. See their Webites for Distributors.

* Lipo, e.g. [this one](http://www.exp-tech.de/polymer-lithium-ion-battery-110mah-5687) (100 mAh is fine for a full day).

* Lipo charger (optional), e.g. [this](https://www.adafruit.com/product/1304) or [this](https://www.adafruit.com/products/1904) from adafruit. 

* Switch (optional but helpfull if you mount a lipo charger).

#### Wiring

Wire the parts as in the following diagram (courtesy to [libxMike](https://github.com/libxmike?tab=following)). 

![libremonitorwirediagramm](https://cloud.githubusercontent.com/assets/10375483/19703622/c866a0d0-9b04-11e6-9471-8056324664b5.jpg)

It is suggested to mount and test everything on a breadboard before soldering the final device. Below are pictures of another LibreMonitor device without lipo charger. As you can see, one can save a lot of space by cutting of the black part of the stacks for Pins GPIO2 to GPIO6, push them through the pin holes of the BM019 and then solder the parts together. Therefore you also have to cut of the stack pins on the other side, too. Furthermore, it is suggested to bend the black part of the other stacks by 90 degrees. Thus you can still plug in the USB Programming Shield (RFD22121) but save some space. 

![libremonitor2_1](https://cloud.githubusercontent.com/assets/10375483/19740419/e9ae9602-9bbe-11e6-98ad-f616d21ae129.jpeg)
![libremonitor2_2](https://cloud.githubusercontent.com/assets/10375483/19740420/e9ce57d0-9bbe-11e6-8a48-0faff5641c39.jpeg)

Another device, this time with a lipo charger:

![libremonitor3_1](https://cloud.githubusercontent.com/assets/10375483/19740504/2d73afbc-9bbf-11e6-8e18-ec32464d08ed.jpeg)
![libremonitor3_2](https://cloud.githubusercontent.com/assets/10375483/19741238/30e8c438-9bc0-11e6-9f30-f5035daf4913.jpeg)

##Suggested readings

[Blog by Pierre Vandevenne](http://type1tennis.blogspot.de) with information on the internals of the Freestyle Libre and suggestions on how to choose slope and offset. Without his work all this would probably not have been possible.


##Similar projects

* [LimiTTer](https://github.com/JoernL/LimiTTer). Similar device, but data is sent to [xDrip+](https://github.com/jamorham/xDrip-plus) Android app.

* [Freestyle Libre Alarm](https://github.com/pimpimmi/LibreAlarm/wiki). Uses as Sony smart watch to read date from the Freestyle Libre and send it to and Android phone.

* [Bluereader](https://www.startnext.com/bluereader) project by [Sandra Kessler](http://unendlichkeit.net/wordpress/) who got funding to build a small neat device. 


##More information to follow soon.
