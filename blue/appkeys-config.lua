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

return appkeys