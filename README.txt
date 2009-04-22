== RHOUSE

* Author: Fernand Galiana
* Source: git://github.com/derailed/rhouse.git
* Discussions: http://groups.google.com/group/rhouse_gem  

== DESCRIPTION

Rhouse allows you to enhance your LinuxMCE home automation system using ruby. The gem
builds on top of LinuxMCE( http://linuxmce.com ) and provides for taping into the
it's c++ core using ruby. Using this gem, you will be able to intercept various 
device events, such as lights, Tv, sensors... and take necessary action using ruby. 
It packs a light web service component that allows you to control devices in your home from
from anywhere around the world...

== FEATURES
* Provides a basic infrastructure to create home automation systems using ruby
* Intercepts devices events and make them available to your ruby programs.
* Send commands to various home automation devices regardless of their protocol.
* Models LinuxMCE persistent store using ActiveRecord.
* MyRhouse.gem: This is a companion gem to showcase some of the things you can
  do with a running system. MyRhouse shows how to create a new worker to intercept
  events as well intergrates a rules engine to make programmable decisions based
  on these events.

== BACKGROUND
There are a multiple approaches to home automation. There are several vendors out
there trying to get a device into your house. We've chosen LinuxMCE because it's a
open source home automation system, provides for a multitude of services and integrates
well with various device protocols ie X10, ZWave, IR, IP, etc... 
Also LinuxMCE has already a built in affiliation with ruby and uses MySql for persistence, 
which makes for an ideal candidate to build rails application on top of.

== HARDWARE
When I was getting started with this project, I've digged up an old p5 I'ved had
laying around. LinuxMCE can run on a variety of hardwares, you can check the wiki
(http://wiki.linuxmce.org) for the supported hardware. Since
the cooling fans eventually drove me out of my mind, I've settled for an Asus EEE
Box (~$300.0) as my main hybrid device. It only draws 20W and it's damn quiet!. 
As I've mentioned there are a multitude of home automation devices out there. 
I've settled for ZWave devices (http://www.z-wavealliance.org) as 
the protocol is feature full and reliable. 
In order to work with ZWave, you'll need a ZWave dongle, that allows you to 
register ZWave devices and establish ZWave communication via USB.
The dongle that I am using is the MicasaVerde dongle ($65) 
(http://shop.micasaverde.com/index.php?main_page=product_info&cPath=110&products_id=151)
ZWave devices can be purchased online thru a variety of vendors 
(SmartHome, ControlThink, Amazon, etc..). 

== SETUP

I realize this is not for the faint of heart.

Hopefully folks will share their experiences and we can join efforts to improve the
docs. 

Still pretty rough through here, but believe me it's worth it and you'll be 
blown by the kind of stuff you can do in your house with this gem and ruby...

LinuxMCE comes with different installation modes: Core/Media Center/Hybrid.
These instructions specifies the installation on an hybrid box.

* Install LinuxMCE - http://wiki.linuxmce.org/index.php/LinuxMCE-0810_alpha2
* Make sure you have all the latest updates
  * > sudo apt-get update
  * > sudo apt-get dist-upgrade
* In order to intercept device events, you will need to register a virtual device
  with the LinuxMCE core. This device will be the connecting point with the Rhouse
  gem to intercept the events and make them available to ruby.
* Setting up the event interceptor device
  * From a web browser login and enter the linuxMCE admin console
    http://my_mce_box/lmce-admin/index.php
  * From the green menu bar choose Advanced -> Configuration -> Devices
  * On the tree on the left - select CORE
  * Click on Create Child Device
    * Set Description to 'Event Interceptor'
    * Click 'Pick device template'
    * Select Device Category 'Logic Handler' (id=142)
    * Select Device Template as 'Generic #1' (id=1725)
    * Click on 'Pick Device Template' button
      * You should now have a new device created note the device id 'Device Info #xxx' xxx is the ID
    * Click the 'View' button next to device template
    * In Command Line enter rh_interceptor
      Will revisit this later but this is going to be the rh_interceptor exec installed by Rhouse
* Install Beanstalkd (http://xph.us/software/beanstalkd/)
  * On my installation I have configured beanstalkd to be automatically launched upon OS
    start. The daemon is setup using port 7777. I have provided my lame init.d script in scripts/beanstalk
    in the gem.
  
At this point you should have an clean install of LinuxMCE and a new event interceptor created.

== INSTALL

NOTE: You will need to configure your ruby env on that box. It does come with ruby (1.8.7 ) installed but on my
install I have updated rubygems to 1.3.1

* sudo gem install derailed-rhouse

From the steps above we now need to tell linuxMCE where to find the newly installed rh_interceptor
ruby script.
  * ssh into you linuxMCE box
  * cd /usr/pluto/bin
  * Create a link as root - ln -s /usr/bin/rh_interceptor
    This will tell linuxMCE to launch the interceptor with the correct device configured in setup with
    the correct id xxx.
  * Rhouse expects the environment variable 'RH_ENV' to be set. Edit your .bashrc script
    and add the following line:
    * export RH_ENV=production
    This will setup the Rhouse environment to production in order to connect to the right database and
    correct configuration on your install box.
  * Restart linuxMCE
   * Either from a shell or from the pluto admin console 
   * Wizard -> Restart -> Reboot

Upon successfull restart you should 'hopefully' see the rh_interceptor as a running process.

* > ps -elf | grep rh 
* /usr/bin/ruby1.8 /usr/pluto/bin/rh_interceptor -d 35 -r localhost -l /var/log/pluto/35_rh_interceptor.log

If not take a look at the pluto log file in /var/log/pluto/pluto.log and see if there was any errors launching
the rh_interceptor script.

== COMMANDS

Rhouse comes bundled with several command line executables.

* rh_console - Specialized IRB console to play with Rhouse. Look at the db,
  run some device commands, etc...
* rh_interceptor - Registers the event interceptor virtual device and registers
  event interest with the router. By default the interceptor will register the 
  following interests:
  * Ligthing Events
  * Sensor Events
  * Camera Events
  * Music Events
  You can only run one rh_interceptor per installation. The rh_interceptor will
  be automatically invoked per the instruction in the intall section above. Once
  an device event is matched, the event will be pushed onto the beanstalk queue,
  for workers consumption.
* rh_rhouse - This web services is currently setup to send out device commands
  to the router. This service must be started for your installation.
* rh_send_msg - Command line utility for sending out commands to devices via
  the router directly.
* rh_ws_client - Connects to the Rhouse web service to send out commands to
  devices. This is the preferred way to send commands to the router. You can
  use this command line util or use the corresponding api call.
  
== LICENSE

(The MIT License)

Copyright (c) 2009

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
