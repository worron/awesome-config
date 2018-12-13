-----------------------------------------------------------------------------------------------------------------------
--                                               Mail settings config                                                --
-----------------------------------------------------------------------------------------------------------------------

-- Here is example data setup for mail check widget.
-- Every item (table) in returned table is for separate mail box.
-- When 'checker' key set to 'script' third party script can be used. It can be arbitrary
-- script returning number of unread messages.
-- With  checker as 'curl_imap' curl request will be used, just fill up other fields accordings example below,
-- but beware storing you passwords in plain text.

local mymaillist = {}

--local mymaillist = {
--	{ checker = "script", script = "/home/user/Documents/scripts/mail/mail-script.py" },
--	{ checker = "curl_imap", mail = "username@gmail.com", password = "userpass", server = "imap.gmail.com" },
--}

return mymaillist
