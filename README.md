# LibreMonitor
##Monitor your Freestyle Libre.

LibreMonitor is a little DIY device that uses near field communication to read data from a Freestyle Libre sensor and transmit it via bluetooth low energy to an iPhone application. LibreMonitor scans the sensor every two minutes. It transfers all the 32 history values for the last eight hours and the 16 trend values for the current time and the last 15 minutes and displays them in a chart and in a table. 

Be aware that only the so called raw data is used and you have to choose slope and intercept yourself to have the application calculate useful glucose values. Values that mostly work fine for my sensors are 0.13 for slope and -20 for offset. Any other internal information such as from the temperature sensors is not yet fully understood and thus neglected,

This code is published for the purpose that others can contribute and help to improve it or use it to improve their own devices.

LibreMonitor has no affiliation of any kind with Abbott. This is a DIY project for research purposes. The code provided here might provide wrong results. You will have to build your own device and are responsible for the results. Use at your own risk.  


##What you need to build a LibreMonitor

####Hardware

Parts needed for a LibreMonitor are

* [BM019 NFC module](http://www.solutions-cubed.com/bm019/) capable of ISO/IEC 15693 commands. Possible sources are [Solutions Cubed LLC](http://www.solutions-cubed.com/bm019/), [Warbutech](http://www.warburtech.co.uk/products/modules/solutions.cubed.bm019.serial.to.nfc.converter/) or 
[Robotshop](http://www.robotshop.com/eu/en/serial-to-nfc-converter-module.html).
* [Simblee](https://www.simblee.com) or [RFDuino](http://www.rfduino.com) and a corresponding USB Programming Shield. I recommend to get a startet kit. See their Webites for Distributors.
* Lipo, e.g. [this one](http://www.exp-tech.de/polymer-lithium-ion-battery-110mah-5687) (100 mAh is fine for a full day).
* Lipo charger (optional), e.g. [this](https://www.adafruit.com/product/1304) or [this](https://www.adafruit.com/products/1904) from adafruit. 
* Switch (optional but helpfull if you mount a lipo charger).

#### Wiring

Wire the parts as in the following diagram (courtesy to [libxMike](https://github.com/libxmike?tab=following)). 


<img src="https://cloud.githubusercontent.com/assets/10375483/19703622/c866a0d0-9b04-11e6-9471-8056324664b5.jpg" width="500">


It is suggested to mount and test everything on a breadboard before soldering the final device. Below are pictures of another LibreMonitor device without lipo charger. As you can see, one can save a lot of space by cutting of the black part of the stacks for Pins GPIO2 to GPIO6, push them through the pin holes of the BM019 and then solder the parts together. Therefore you also have to cut of the stack pins on the other side, too. Furthermore, it is suggested to bend the black part of the other stacks by 90 degrees. Thus you can still plug in the USB Programming Shield (RFD22121) but save some space. 


<img src="https://cloud.githubusercontent.com/assets/10375483/19740419/e9ae9602-9bbe-11e6-98ad-f616d21ae129.jpeg" width="300">
<img src="https://cloud.githubusercontent.com/assets/10375483/19740420/e9ce57d0-9bbe-11e6-8a48-0faff5641c39.jpeg" width="300">



Another device, this time with a lipo charger:


<img src="https://cloud.githubusercontent.com/assets/10375483/19740504/2d73afbc-9bbf-11e6-8e18-ec32464d08ed.jpeg" width="300">
<img src="https://cloud.githubusercontent.com/assets/10375483/19741238/30e8c438-9bc0-11e6-9f30-f5035daf4913.jpeg" width="300">


####Software for the Simblee

The software to program the Simblee is standard Arduino code. It consists of LibreMonitor.ino and the library contained in LibreMonitorArduinoLibrary.zip. Refer to the [Simblee quick start guide](https://www.simblee.com/Simblee_Quickstart_Guide_v1.0.pdf) on the [Simblee website](https://www.simblee.com) on how to program the Simblee. If you wired your LibreMonitor as described above don't forget to reconfigure the SPI pins of the Simblee in the variant.h file (see the wiring information in LibreMonitor.ino for more information on this)


##iOS application

The iOS application requires Xcode 8, swift 3.0 and iOS 10. Download the Xcode project. Run [cocopoads](https://cocoapods.org) to install the [charts](https://github.com/danielgindi/Charts) library, needed for the blood sugar graph. Build the application and run it on the phone and start it. If you want to receive notifications for high or low glucose values and have a badge icon displayed, allow for the corresponding settings, when asked. Once the app is running set values for slope and offset (e.g. 0.13 and -20, press the corresponding row to get into the settings view). Connect to your Simblee by pressing "connect". Once the Simblee ist detected and connected the "Simblee status" should change to "Notifying" and be green. Place the LibreMonitor device above your Freestyle Libre and after no more than two minutes the data should be displayed or refreshed. See the scrrenshots below. 


<img src="https://cloud.githubusercontent.com/assets/10375483/19742181/19d18f24-9bc4-11e6-999d-449edba439b9.PNG" width="300">
<img src="https://cloud.githubusercontent.com/assets/10375483/19742182/19f6b10a-9bc4-11e6-9c88-f850625fdbd4.PNG" width="300">


<img src="https://cloud.githubusercontent.com/assets/10375483/19742183/19f9efbe-9bc4-11e6-81a4-9bed01c2f865.PNG" width="300">
<img src="https://cloud.githubusercontent.com/assets/10375483/19742184/19fcf272-9bc4-11e6-8cd8-d02139f3616b.PNG" width="300">


##Suggested readings

[Blog by Pierre Vandevenne](http://type1tennis.blogspot.de) with information on the internals of the Freestyle Libre and suggestions on how to choose slope and offset. Without his work all this would probably not have been possible.


##Similar projects

* [LimiTTer](https://github.com/JoernL/LimiTTer). Similar device, but data is sent to [xDrip+](https://github.com/jamorham/xDrip-plus), an Android app.
* [Freestyle Libre Alarm](https://github.com/pimpimmi/LibreAlarm/wiki). Uses as Sony smart watch to read data from the Freestyle Libre and send it to an Android phone.
* [Bluereader](https://www.startnext.com/bluereader) project by [Sandra Kessler](http://unendlichkeit.net/wordpress/) who got funding to build a small neat device. I intend to adapt this project to work with bluereader once the first devices are available.
* [Android reader application](https://github.com/vicktor/FreeStyleLibre-NFC-Reader) by Viktor Bautista that was helpful at the beginning of this work.


##More information to follow soon.
