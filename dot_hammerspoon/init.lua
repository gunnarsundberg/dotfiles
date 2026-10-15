-- Match the Niri app-launch bindings on macOS: Option+Return/B/E.
local function bindApp(key, bundleID)
    hs.hotkey.bind({"alt"}, key, function()
        hs.application.launchOrFocusByBundleID(bundleID)
    end)
end

bindApp("return", "com.mitchellh.ghostty")
bindApp("b", "org.mozilla.firefox")
bindApp("e", "com.apple.finder")
