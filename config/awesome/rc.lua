-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
--require("vicious")

-- Load Debian menu entries
require("debian.menu")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--local theme_path = awful.util.getdir("config") .. "/current_theme/theme.lua"
local theme_path = "/home/acm/.config/awesome/themes/sky/theme.lua"
--local theme_path = "/usr/share/awesome/themes/sky/theme.lua"
beautiful.init(theme_path)
theme.border_focus = "#ff0000"
-- 
-- mythememenu = {}
-- 
-- function theme_load(theme)
--    local cfg_path = awful.util.getdir("config")
-- 
--    -- Create a symlink from the given theme to /home/user/.config/awesome/current_theme
--    awful.util.spawn("ln -sfn " .. cfg_path .. "/themes/" .. theme .. " " .. cfg_path .. "/current_theme")
--    awesome.restart()
-- end
-- 
-- function theme_menu()
--    -- List your theme files and feed the menu table
--    local cmd = "ls -1 " .. awful.util.getdir("config") .. "/themes/"
--    local f = io.popen(cmd)
-- 
--    for l in f:lines() do
--        local item = { l, function () theme_load(l) end }
--        table.insert(mythememenu, item)
--    end
-- 
--    f:close()
-- end
-- 
-- 
-- -- Generate your table at startup or restart
-- theme_menu()

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}


-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "themes", mythememenu },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, " %a %b %d, %H:%M:%S (%s) ", 0.25)

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters

--     cpuwidget = awful.widget.graph()
--     cpuwidget:set_width(50)
--     cpuwidget:set_background_color("#494B4F")
--     cpuwidget:set_color("#FF5656")
--     cpuwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
--     vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 3)

    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        cpuwidget,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- NOTE(acm): This is a total hack. This should use the same
-- mechanisms for relational client moves, but that stuff is local to
-- awful, so we cant. This won't work for monitor arrangements that
-- aren't linear in the x coordinate.
local screen_relative_left = -1
local screen_relative_right = 1

if screen.count() > 1 then
    if screen[1].geometry.x > screen[2].geometry.x then
        screen_relative_left = 1
        screen_relative_right = -1
    end
end

-- Return true whether client B is in the right direction
-- compared to client A.
-- @param dir The direction.
-- @param cA The first client.
-- @param cB The second client.
-- @return True if B is in the direction of A.
local function is_in_direction(dir, cA, cB)
    local gA = cA:geometry()
    local gB = cB:geometry()
    if dir == "up" then
        return gA.y > gB.y
    elseif dir == "down" then
        return gA.y < gB.y
    elseif dir == "left" then
        return gA.x > gB.x
    elseif dir == "right" then
        return gA.x < gB.x
    end
    return false
end

-- Calculate distance between two points.
-- i.e: if we want to move to the right, we will take the right border
-- of the currently focused client and the left side of the checked client.
-- This avoid the focus of an upper client when you move to the right in a
-- tilebottom layout with nmaster=2 and 5 clients open, for instance.
-- @param dir The direction.
-- @param cA The first client.
-- @param cB The second client.
-- @return The distance between the clients.
local function calculate_distance(dir, cA, cB)
    local gA = cA:geometry()
    local gB = cB:geometry()

    if dir == "up" then
        gB.y = gB.y + gB.height
    elseif dir == "down" then
        gA.y = gA.y + gA.height
    elseif dir == "left" then
        gB.x = gB.x + gB.width
    elseif dir == "right" then
        gA.x = gA.x + gA.width
    end

    return math.sqrt(math.pow(gB.x - gA.x, 2) + math.pow(gB.y - gA.y, 2))
end

local capi =
{
    client = client,
    mouse = mouse,
    screen = screen,
}

-- Get the nearest client in the given direction.
-- @param dir The direction, can be either "up", "down", "left" or "right".
-- @param c Optional client to get a client relative to. Else focussed is used.
local function get_client_in_direction(dir, c)
    local sel = c or capi.client.focus
    if sel then
        local geometry = sel:geometry()
        local dist, dist_min
        local target = nil
        local cls = awful.client.visible()

        -- We check each client.
        for i, c in ipairs(cls) do
            -- Check geometry to see if client is located in the right direction.
            if is_in_direction(dir, sel, c) then

                -- Calculate distance between focused client and checked client.
                dist = calculate_distance(dir, sel, c)

                -- If distance is shorter then keep the client.
                if not target or dist < dist_min then
                    target = c
                    dist_min = dist
                end
            end
        end

        return target
    end
end

--- Focus a client by the given direction.
-- @param dir The direction, can be either "up", "down", "left" or "right".
-- @param c Optional client.
local function acm_focus_bydirection(dir, c)
    local sel = c or capi.client.focus
    if sel then
        local target = get_client_in_direction(dir, sel)

        -- If we found a client to focus, then do it.
        if target then
            capi.client.focus = target
        end
    end
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "Left",  function() acm_focus_bydirection("left") end ),
    awful.key({ modkey,           }, "Right", function() acm_focus_bydirection("right") end  ),
    awful.key({ modkey,           }, "Up",    function () acm_focus_bydirection("up")    end ),
    awful.key({ modkey,           }, "Down",  function () acm_focus_bydirection("down")  end ),

    awful.key({ modkey, "Shift"   }, "Left",  function () awful.screen.focus_relative(screen_relative_left) end ),
    awful.key({ modkey, "Shift"   }, "Right", function () awful.screen.focus_relative(screen_relative_right) end ),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),



    awful.key({ modkey, }, "s", function ()
                                    awful.prompt.run({ prompt = "ssh: " },
                                                     mypromptbox[mouse.screen].widget,
                                                     function(h)
                                                         awful.util.spawn(terminal .. " -e ssh " .. h)
                                                     end,
                                                     function(cmd, cur_pos, ncomp)
                                                         -- get the hosts
                                                         local hosts = {}

                                                         f = io.popen('awk \'{ print $1 }\' ' .. os.getenv("HOME") .. '/.ssh/known_hosts /etc/ssh/ssh_known_hosts | grep \'^[a-z,A-Z]\' | awk -F, \'{ print $1 }\' | sort | uniq')
                                                         for host in f:lines() do
                                                             table.insert(hosts, host)
                                                         end
                                                         f:close()

                                                         -- abort completion under certain circumstances
                                                         if #cmd == 0 or (cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " ") then
                                                             return cmd, cur_pos
                                                         end
                                                         -- match
                                                         local matches = {}
                                                         table.foreach(hosts, function(x)
                                                                                  if hosts[x]:find("^" .. cmd:sub(1,cur_pos)) then
                                                                                      table.insert(matches, hosts[x])
                                                                                  end
                                                                              end)
                                                         -- if there are no matches
                                                         if #matches == 0 then
                                                             return
                                                         end
                                                         -- cycle
                                                         while ncomp > #matches do
                                                             ncomp = ncomp - #matches
                                                         end
                                                         -- return match and position
                                                         return matches[ncomp], cur_pos
                                                     end,
                                                     awful.util.getdir("cache") .. "/ssh_history")
                                end),


    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        -- local screen = mouse.screen
                        for s = 1, screen.count() do
                            if tags[s][i] then
                                awful.tag.viewonly(tags[s][i])
                            end
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
