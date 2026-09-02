# SponsorBlock for PotPlayer
 Modified version of the default PotPlayer YouTube extension that adds [SponsorBlock](https://sponsor.ajay.app/) segments as Chapters.

 There's no support for submitting segments, as I don't know if it's even possible with the extension API. Help for this would be greatly appreciated.
 
## Version v2
Version v2 for older versions of Pot Player, for users who encounter the “HostDecodeSigUrl” error upon launch

## Installation
 Copy both the `.as` and the `.ico` files into the `Extension\Media\PlayParse` folder, by default located at `C:\Program Files\DAUM\PotPlayer`.

## Configuration and Usage
### Use as default
 To use as the default when opening youtube URLs, go to  `Preferences (F5) > Extensions > Media Playlist/Playitem` and move it above the default.

### Skipping
 To choose what types of segments to skip, go to `PotPlayer (or right rlick) menu > Playback > Skip > Skip Setup`, tick "Enable skip feature" and "Chapter title(s)", and add the desired types to the list, separated by semicolons. If the title of the chapters includes any of the strings in the list (case insensitive), it will be skipped. The chapter titles are:
 - SB - Sponsor
 - SB - Self Promotion
 - SB - Interaction Reminder
 - SB - Intro
 - SB - Outro
 - SB - Preview
 - SB - No Music
 - SB - Non-essential Filler

## Issues
### Known Issues
- Overlapping segments don't work  too well
### Contrubuting
If you come across any bugs or problems, or have any ideas on how to improve this, please feel free to open an issue!
