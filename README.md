# Red Flat Awesome WM config
Custom config for [Awesome WM](http://awesome.naquadah.org).

This config is compatible with AwesomeWM version 4.0 and newer.

## Screenshots
![](https://github.com/worron/awesome-config/wiki/images/v400/ruby.png)
<p align="center"><a href="https://youtu.be/OoSts990-lY">Video Demo</a></p>

## Description
Advanced user config for Awesome WM consist of a bunch of new widgets, 
features, tiling schemes, and some reworked standard widgets. 
This repository provide only config examples and themes. 
Main code base can be found in `redflat` submodule.

#### Core Features
* Full color control, including widget icons;
* True vector scaling for widget icons (gdkpixbuf required);
* New unique panel widgets and some reworked from standard lib;
* A pack of desktop widgets;
* A pack of widgets for applications control (quick launch, application switch, ect);
* Several minor improvements for menu widget;
* Alternative titlebars with several visual schemes;
* Active screen edges;
* Keys sequences;
* Advanced hotkeys helper;
* Special window control mode which allow use individual hotkeys for different layouts;
* New tiling layout to build your placement scheme manually;

## Dependencies
#### Main
* Awesome WM 4.0+

#### Widgets
| widget                 | type          | utility             |
| -------------          |---------------| -------------       |
| new mail indicator     | panel         | curl/user scripts   |
| system updates         | panel         | apt-get*            |
| volume control         | panel         | pacmd               |
| brightness control     | floating      | xbacklight          |
| mpris2 player          | floating      | dbus-send           |
| CPU temperature        | desktop       | lm-sensors          |
| HDD temperature        | desktop       | smartctl**          |
| Nvidia GPU temperature | desktop       | nvidia-smi/optirun  |
| torrent info           | desktop       | transmission-remote |

\* Actually any one-liner written for your package manager.  
\*\* Should be configured to run from user.

## Installation and Usage

#### Installation
Copy scripts to WM setting folder. 
Simple way to do so with `git`
```shell
$ git clone https://github.com/worron/awesome-config.git ~/.config/awesome --recursive
```
Then edit `rc.lua` to select wanted config.

#### Start with Colorless
Config `rc-colorless.lua` is basic setup. 
It provide general features only and should work without any additional editing.
After installing colorless config you can set you own colors,
fonts, hotkeys and then start porting wanted widgets from colored configs.
It's the most safe and reliable way to use this config.

#### Start with Colors
Colored are my personal configs.
It's full featured setup filled with widgets
preconfigured for certain software and hardware environment.
Should be carefully edited and adapted before using.
This way suitable mostly to experienced Awesome WM users.
Some things to pay attention:

* Better to disable desktop section from the start.
There a lot of hardware specific widgets which can be configured later.
* Third party user applications set in environment and autostart sections.
* Carefully check "Panel widgets" section, reconfigure or disable widgets there.
Do not forget remove disabled panel widgets from `awful.screen.connect_for_each_screen` function.
* Rules and hotkeys are another parts of config which definitely need revising.  

#### Tips
Hotkeys helper bound to `Mod4`+`F1` (with holding modkey) by default,
It will show you all hotkeys available at the current moment.

Theme files is very valuable part of config.
Some widgets appearance can be changed dramatically with themes.

This config was designed to work with composite manager (e.g. compton).

[ACYLS](https://github.com/worron/ACYLS) icon pack is very good complement for this configs.
Some widgets was designed with this pack in mind.

There are lot shared parts between configs and themes, pay attention to `require` directives.

[Xephyr](https://freedesktop.org/wiki/Software/Xephyr/) is excellent tool for Awesome WM deep customization.

## Themes
This config isn't compatible with standard Awesome WM themes
and its themes not compatible with default config.

#### Structure
There is some inheritance and code sharing between theme files.

Colorless `themes/colorless/theme.lua` is base and only one self-sufficient theme.
It contains list of all appearance variables for `redflat` widgets with
commentaries. Also it directly define style for `rc-colorless` config.

Colored `themes/colored/theme.lua` is theme which contain some
shared settings (e.g. fonts) for different color configs. It inherits all data from
colorless theme and overwrites some values. Doesn't used directly from configs.

Color specified themes (e.g. `themes/blue/theme.lua` for `rc-blue.lua`)
are inherit all data from colored and overwrite config specific values. 
