# Red Flat Awesome WM config
Custom config for [Awesome WM](http://awesome.naquadah.org).

This config is compatible with AwesomeWM 4 only, check `v356` branch for older (v3.5.6 - v3.5.9) version.

## Screenshots
![](https://github.com/worron/awesome-config/wiki/images/v400/red.png)
---
![](https://github.com/worron/awesome-config/wiki/images/v400/blue.png)
---
![](https://github.com/worron/awesome-config/wiki/images/v400/orange.png)
---
![](https://github.com/worron/awesome-config/wiki/images/v400/green.png)
<p align="center"><a href="https://youtu.be/OoSts990-lY">Video Demo</a></p>

## Description
Advanced user config for Awesome WM, It consist of a bunch of new widgets, features, tiling schemes, and some reworked standart widgets. This repository provide only config examples and themes. Main code base can be found in `redflat` submodule. Should be mentioned, that originally this scripts was created for Awesome v3.5.6 and then roughly ported to latest version, thereby some part of code may seem too messed and outdated.  So code improvement fixes are welcomed.

#### General Feature List
* Full color control, including widget icons;
* True vector scaling for widget icons (gdkpixbuf required);
* New unique panel widgets and some reworked from standart lib;
* A pack of desktop widgets;
* A pack of widgets for applications control (quick launch, application switch, ect);
* Several minor improvements for menu widget;
* Alternative titlebars with several visual schemes;
* Active screen edges;
* Emacs-like key sequences;
* Advanced hotkeys helper;
* Special window control mode which allow use individual hokeys for different layouts;
* New tiling layout to build your placement scheme manually;

## Dependencies
#### Main
* Awesome WM 4.0+

#### Widgets
| widget                 | type          | utility                                     |
| -------------          | ------------- | -------------                               |
| new mail indicator     | panel         | curl/user scripts                           |
| keyboard layout        | panel         | kbdd, dbus-send                             |
| system upgrades        | panel         | apt-get                                     |
| volume control         | panel         | pacmd                                       |
| brightness control     | floating      | xbacklight/unity-settings-daemon, dbus-send |
| CPU temperature        | desktop       | lm-sensors                                  |
| HDD temperature        | desktop       | hddtemp, curl                               |
| Nvidia GPU temperature | desktop       | nvidia-smi                                  |
| torrent info           | desktop       | transmission-remote                         |

## Instalation and Usage

#### Instalation
Copy all scripts to you setting folder
```shell
$ git clone https://github.com/worron/awesome-config.git ~/.config/awesome --recursive
```
and then edit `rc.lua` to select wanted config.

#### Start with Colorless
Config `rc-colorless.lua` is some kind of basic config, it consist only general features and should work without any additional editing.  You can set colorless config, set you own colors, fonts, hotkeys and then port any widget you want from colored configs.

#### Start with Colors
Colored configs is full featured setup designed to demonstrate all the power of `redflat` extension module. It contains some personal setting, so if you want to use colored config you should carefully edit "Panel widgets", "Desktop widgets", "Autostart user applications" sections, hotkeys and enviroment vars first.

#### Tips
Hotkeys helper bound to `Mod4`+`F1` (with holding modkey) by default, It will show you all hotkeys available at the current moment.

Theme files is very valuable part of config. Some widgets appearance can be changed dramatically with themes.

This config was designed to work with composite manager (e.g. compton).

[ACYLS](https://github.com/worron/ACYLS) icon pack is very good complement for this configs. Some widgets was disigned with this pack in mind.

## Themes
Several icon packs were used to create custom WM themes:
* Any Color You Like Simple
* Open Iconic
* Android Vector Icons
