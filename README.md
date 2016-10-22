# LibreMonitor
Monitor your Freestyle Libre.

LibreMonitor is a little DIY device that uses near field communication to read data from a Freestyle Libre sensor and transmit it via bluetooth low energy to an iPhone application. LibreMonitor scans the sensor every two minutes. It transfers all the 32 history values for the last eight hours and the 16 trend values for the last 15 minutes and displays them in a chart. Be aware that only the so called raw data is used and you have to choose slope and intercept to calculate useful glucose values. Values that mostly work fine for my sensors are .13 for slope and -20 for offset. Any other internal information such as from the temperature sensors is not yet fully understood and thus neglected,

LibreMonitor has is no affiliation of any kind with Abbott. This is a DIY project for research purposes. The code provided here might provide wrong results. You will have to build your own device and are responsible for the results. Use at your own risk. 

This code is published for the purpose that others can contribute and help to improve it or use it to improve their own devices. 

Corresponding ino file and more information to follow soon.
