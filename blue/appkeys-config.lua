-----------------------------------------------------------------------------------------------------------------------
--                                        Third-party applications keys sheet                                        --
-----------------------------------------------------------------------------------------------------------------------
-- This file provides table to build hotkeys helpers for third-party applications.
-- The key lists here are purely descriptive, have nothing to do with real application configs.


local appkeys = {}

appkeys["urxvt"] = {
	style = { column = 2, geometry = { width = 1200, height = 660 } },
	pack = {
		{
			{ "Control" }, "l", nil,
			{ description = "Clear the screen", group = "Control" }
		},
		{
			{ "Control" }, "s", nil,
			{ description = "Stops the output to the screen", group = "Control" }
		},
		{
			{ "Control" }, "q", nil,
			{ description = "Allow output to the screen", group = "Control" }
		},
		{
			{ "Control" }, "c", nil,
			{ description = "Terminate the command", group = "Control" }
		},
		{
			{ "Control" }, "z", nil,
			{ description = "Suspend/stop the command", group = "Control" }
		},

		{
			{ "Control" }, "a", nil,
			{ description = "Go to the start of the command line", group = "Editing" }
		},
		{
			{ "Control" }, "e", nil,
			{ description = "Go to the end of the command line", group = "Editing" }
		},
		{
			{ "Control" }, "k", nil,
			{ description = "Delete from cursor to the end of the command line", group = "Editing" }
		},
		{
			{ "Control" }, "u", nil,
			{ description = "Delete from cursor to the start of the command line", group = "Editing" }
		},
		{
			{ "Control" }, "w", nil,
			{ description = "Delete from cursor to start of word ", group = "Editing" }
		},
		{
			{ "Control" }, "y", nil,
			{ description = "Paste word or text", group = "Editing" }
		},
		{
			{ "Control" }, "xx", nil,
			{ description = "Move between start of command line and cursor", group = "Editing" }
		},
		{
			{ "Alt" }, "b", nil,
			{ description = "Move backward one word", group = "Editing" }
		},
		{
			{ "Alt" }, "f", nil,
			{ description = "Move forward one word", group = "Editing" }
		},
		{
			{ "Alt" }, "d", nil,
			{ description = "Delete to end of word starting at cursor", group = "Editing" }
		},
		{
			{ "Alt" }, "c", nil,
			{ description = "Capitalize to end of word starting at cursor", group = "Editing" }
		},
		{
			{ "Alt" }, "u", nil,
			{ description = "Make uppercase from cursor to end of word", group = "Editing" }
		},
		{
			{ "Alt" }, "l", nil,
			{ description = "Make lowercase from cursor to end of word", group = "Editing" }
		},
		{
			{ "Alt" }, "t", nil,
			{ description = "Swap current word with previous", group = "Editing" }
		},
		{
			{ "Control" }, "f", nil,
			{ description = "Move forward one character", group = "Editing" }
		},
		{
			{ "Control" }, "b", nil,
			{ description = "Move backward one character", group = "Editing" }
		},
		{
			{ "Control" }, "d", nil,
			{ description = "Delete character under the cursor", group = "Editing" }
		},
		{
			{ "Control" }, "h", nil,
			{ description = "Delete character before the cursor", group = "Editing" }
		},
		{
			{ "Control" }, "t", nil,
			{ description = "Swap character under cursor with the previous one", group = "Editing" }
		},

		{
			{ "Control" }, "r", nil,
			{ description = "Search the history backwards", group = "Recall" }
		},
		{
			{ "Control" }, "g", nil,
			{ description = "Escape from history searching mode", group = "Recall" }
		},
		{
			{ "Control" }, "p", nil,
			{ description = "Previous command in history", group = "Recall" }
		},
		{
			{ "Control" }, "n", nil,
			{ description = "Next command in history", group = "Recall" }
		},
		{
			{ "Alt" }, ".", nil,
			{ description = "Use the last word of the previous command", group = "Recall" }
		},

		{
			{}, "!!", nil,
			{ description = "Run last command", group = "Bang" }
		},
		{
			{}, "!blah", nil,
			{ description = "Run the most recent command that starts with ‘blah’", group = "Bang" }
		},
		{
			{}, "!blah:p", nil,
			{ description = "Print out the command that !blah would run", group = "Bang" }
		},
		{
			{}, "!$", nil,
			{ description = "The last word of the previous command", group = "Bang" }
		},
		{
			{}, "!$:p", nil,
			{ description = "Print out the word that !$ would substitute", group = "Bang" }
		},
		{
			{}, "!*", nil,
			{ description = "The previous command except for the last word", group = "Bang" }
		},
		{
			{}, "!*:p", nil,
			{ description = "Print out what !* would substitute", group = "Bang" }
		},
	}
}


appkeys["mpv"] = {
	style = { column = 3, geometry = { width = 1600, height = 720 } },
	pack = {
		{
			{}, "f", nil,
			{ description = "Toggle fullscreen", group = "General" }
		},
		{
			{}, "s", nil,
			{ description = "Take a screenshot", group = "General" }
		},
		{
			{ "Shift" }, "s", nil,
			{ description = "Take a screenshot without subtitles", group = "General" }
		},
		{
			{}, "q", nil,
			{ description = "Quit", group = "General" }
		},
		{
			{ "Shift" }, "q", nil,
			{ description = "Quit saving current position", group = "General" }
		},
		{
			{}, "o", nil,
			{ description = "Show progress", group = "General" }
		},
		{
			{ "Shift" }, "o", nil,
			{ description = "Toggle show progress", group = "General" }
		},
		{
			{}, "F9", nil,
			{ description = "Show the list of audio and subtitle", group = "General" }
		},
		{
			{"Shift"}, "a", nil,
			{ description = "Cycle aspect ratio", group = "General" }
		},

		{
			{}, "F8", nil,
			{ description = "Show the playlist", group = "Playlist" }
		},
		{
			{ "Shift" }, ",", nil,
			{ description = "Forward in playlist", group = "Playlist" }
		},
		{
			{ "Shift" }, ".", nil,
			{ description = "Backward in playlist", group = "Playlist" }
		},

		{
			{}, "Space", nil,
			{ description = "Play/pause", group = "Playback" }
		},
		{
			{}, "[", nil,
			{ description = "Decrease speed", group = "Playback" }
		},
		{
			{}, "]", nil,
			{ description = "Increase speed", group = "Playback" }
		},
		{
			{}, "{", nil,
			{ description = "Halve current speed", group = "Playback" }
		},
		{
			{}, "}", nil,
			{ description = "Double current speed", group = "Playback" }
		},
		{
			{}, "l", nil,
			{ description = "Set/clear A-B loop points", group = "Playback" }
		},
		{
			{ "Shift" }, "l", nil,
			{ description = "Toggle infinite looping", group = "Playback" }
		},
		{
			{}, "Backspace", nil,
			{ description = "Reset speed to normal", group = "Playback" }
		},

		{
			{}, "m", nil,
			{ description = "Mute/unmute", group = "Audio" }
		},
		{
			{}, "9", nil,
			{ description = "Decrease volume", group = "Audio" }
		},
		{
			{}, "0", nil,
			{ description = "Increase volume", group = "Audio" }
		},
		{
			{ "Control" }, "-", nil,
			{ description = "Decrease audio delay", group = "Audio" }
		},
		{
			{ "Control" }, "+", nil,
			{ description = "Increase audio delay", group = "Audio" }
		},
		{
			{}, "#", nil,
			{ description = "Cycle through audio tracks", group = "Audio" }
		},

		{
			{}, "PageUp", nil,
			{ description = "Next chapter", group = "Navigation" }
		},
		{
			{}, "PageDn", nil,
			{ description = "Previous chapter", group = "Navigation" }
		},
		{
			{}, ",", nil,
			{ description = "Previous frame", group = "Navigation" }
		},
		{
			{}, ".", nil,
			{ description = "Next frame", group = "Navigation" }
		},
		{
			{}, "Right", nil,
			{ description = "Forward 5 seconds", group = "Navigation" }
		},
		{
			{}, "Left", nil,
			{ description = "Backward 5 seconds", group = "Navigation" }
		},
		{
			{}, "Up", nil,
			{ description = "Forward 60 seconds", group = "Navigation" }
		},
		{
			{}, "Down", nil,
			{ description = "Backward 60 seconds", group = "Navigation" }
		},
		{
			{ "Control" }, "Left", nil,
			{ description = "Seek to the previous subtitle", group = "Navigation" }
		},
		{
			{ "Control" }, "Right", nil,
			{ description = "Seek to the next subtitle", group = "Navigation" }
		},
		{
			{ "Shift" }, "Backspace", nil,
			{ description = "Undo  the  last  seek", group = "Navigation" }
		},
		{
			{ "Control", "Shift" }, "Backspace", nil,
			{ description = "Mark the current position", group = "Navigation" }
		},

		{
			{}, "v", nil,
			{ description = "Show/hide subtitles", group = "Subtitles" }
		},
		{
			{}, "j", nil,
			{ description = "Next subtitle", group = "Subtitles" }
		},
		{
			{ "Shift" }, "j", nil,
			{ description = "Previous subtitle", group = "Subtitles" }
		},
		{
			{}, "z", nil,
			{ description = "Increase subtitle delay", group = "Subtitles" }
		},
		{
			{}, "x", nil,
			{ description = "Decrease subtitle delay", group = "Subtitles" }
		},
		{
			{}, "r", nil,
			{ description = "Move subtitles up", group = "Subtitles" }
		},
		{
			{}, "t", nil,
			{ description = "Move subtitles down", group = "Subtitles" }
		},
		{
			{}, "u", nil,
			{ description = "Style overrides on/off", group = "Subtitles" }
		},


		{
			{}, "1", nil,
			{ description = "Decrease contrast", group = "Video" }
		},
		{
			{}, "2", nil,
			{ description = "Increase contrast", group = "Video" }
		},
		{
			{}, "3", nil,
			{ description = "Decrease brightness", group = "Video" }
		},
		{
			{}, "4", nil,
			{ description = "Increase brightness", group = "Video" }
		},
		{
			{}, "5", nil,
			{ description = "Decrease gamma", group = "Video" }
		},
		{
			{}, "6", nil,
			{ description = "Increase gamma", group = "Video" }
		},
		{
			{}, "7", nil,
			{ description = "Decrease saturation", group = "Video" }
		},
		{
			{}, "8", nil,
			{ description = "Increase saturation", group = "Video" }
		},

		{
			{}, "w", nil,
			{ description = "Decrease pan-and-scan range", group = "Zoom" }
		},
		{
			{}, "e", nil,
			{ description = "Increase pan-and-scan range", group = "Zoom" }
		},
		{
			{ "Alt" }, "-", nil,
			{ description = "Decrease zoom", group = "Zoom" }
		},
		{
			{ "Alt" }, "+", nil,
			{ description = "Increase zoom", group = "Zoom" }
		},
		{
			{ "Alt" }, "Backspace", nil,
			{ description = "Reset zoom", group = "Zoom" }
		},
		{
			{ "Alt" }, "Arrow", nil,
			{ description = "Move the video rectangle", group = "Zoom" }
		},
	}
}


return appkeys