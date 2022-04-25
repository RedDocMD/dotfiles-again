import           Data.List                   (intercalate)
import           System.Exit
import           XMonad
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.DynamicProperty
import           XMonad.Hooks.EwmhDesktops   (ewmh, ewmhFullscreen)
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers  (isDialog, doSink)
import           XMonad.Hooks.StatusBar
import           XMonad.Hooks.StatusBar.PP
import           XMonad.Layout.Spacing       (spacing)
import qualified XMonad.StackSet             as W
import           XMonad.Util.EZConfig        (additionalKeysP, removeKeysP)
import           XMonad.Util.Loggers
import           XMonad.Util.NamedScratchpad
import           XMonad.Util.SpawnOnce       (spawnOnce)

myModMask = mod4Mask  -- Rebind Mod to Super Key
myTerminal = "alacritty"

myAdditionalKeys = [ ("M-p", spawn "ulauncher-toggle")
                   , ("M-a", spawn "alacritty -e ranger")
                   , ("M-M1-q", io (exitWith ExitSuccess))
                   , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
                   , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
                   , ("M1-C-l", spawn "slock")
                   , ("M-C-s", namedScratchpadAction myScratchpads "spotify")
                   , ("M-C-t", namedScratchpadAction myScratchpads "term")
                   , ("M1-C-f", sendMessage $ JumpToLayout "Full")
                   , ("M1-C-t", sendMessage $ JumpToLayout "Tall")
                   , ("M-b", sendMessage ToggleStruts)
                   ] ++
                   [ (otherModMasks ++ "M-" ++ [key], action tag)
                     | (tag, key) <- zip myWorkspaces "1234567890"
                     , (otherModMasks, action) <- [ ("", windows . W.greedyView),
                                                    ("S-", windows . W.shift) ]
                   ]

myRemoveKeys = [ "M-S-q" ]

myLayout = avoidStruts . spacing 7 $ tiled ||| Mirror tiled ||| Full
    where
        tiled = Tall nmaster delta ratio
        nmaster = 1
        ratio   = 1/2
        delta   = 3/100

trayerCmd = intercalate
            " "
            [ "trayer"
            , "--edge top"
            , "--align right"
            , "--width 8"
            , "--expand true"
            , "--heighttype pixel"
            , "--height 20"
            , "--transparent true"
            , "--alpha 50"
            , "--tint 0x18191a"
            , "--SetPartialStrut true"
            , "--SetDockType true" ]

myStartupHook = do
     spawnOnce "ulauncher --no-window"
     spawnOnce "nitrogen --restore"
     spawnOnce "picom"
     spawnOnce "wmname LG3D"
     spawnOnce "dunst"
     spawnOnce "blueman-applet"
     spawnOnce "volctl"
     spawnOnce "nm-applet"
     spawnOnce "xsetroot -cursor_name left_ptr"
     spawnOnce trayerCmd

myXmobarPP :: PP
myXmobarPP = filterOutWsPP [scratchpadWorkspaceTag] $
             def { ppCurrent = xmobarBorder "Bottom" "#fba922" 2
                 , ppVisible = withWindows
                 , ppHidden = withWindows
                 , ppHiddenNoWindows = noWindows
                 , ppVisibleNoWindows = Just noWindows
                 , ppUrgent = xmobarBorder "Bottom" "#9b0a20" 2
                 , ppOrder = \(ws:_:t:rest) -> [ws, t] ++ rest
                 , ppSep = "    "
                 }
      where
            noWindows = xmobarColor "#555555" ""
            withWindows = xmobarColor "#ffaa00" ""

myWorkspaces = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

myScratchpads :: [NamedScratchpad]
myScratchpads = [ NS "spotify" spotifySpawn spotifyQuery spotifyManage
                , NS "term" termSpawn termQuery termManage
                ]
    where
        spotifySpawn = "spotify"
        spotifyQuery = className =? "Spotify"
        spotifyManage = customFloating $ W.RationalRect l t w h
            where
               h = 0.9
               w = 0.9
               t = 0.95 - h
               l = 0.95 - w
        termClass = "alacritty_scratch"
        termSpawn = "alacritty --class " ++ termClass
        termQuery = appName =? termClass
        termManage = spotifyManage

scratchpadManageHook = namedScratchpadManageHook myScratchpads

manageZoomHook =
    composeAll $
      [ (className =? zoomClassName) <&&> shouldFloat <$> title --> doFloat
      , (className =? zoomClassName) <&&> shouldSink <$> title  --> doSink
      ]
    where
        zoomClassName = "zoom"
        tileTitles =
            [ "Zoom - Free Account"
            , "Zoom - Licensed Account"
            , "Zoom"
            , "Zoom Meeting"
            ]
        shouldFloat = flip notElem tileTitles
        shouldSink  = flip elem tileTitles

myManageHook = composeAll
      [ isDialog                         --> doFloat
      , className =? "Chromium"          --> doShift (myWorkspaces !! 1)
      , stringProperty "WM_NAME" =? "Firefox Developer Edition" --> doShift (myWorkspaces !! 1)
      , className =? "JetBrains Toolbox" --> doFloat
      , className =? "Bitwarden"         --> doFloat
      ]
      <+> manageZoomHook
      <+> scratchpadManageHook

myStatusBar = statusBarProp "xmobar ~/.config/xmobar/xmobarrc" (pure myXmobarPP)

main = xmonad
    . withSB myStatusBar
    . ewmhFullscreen
    . ewmh
    . docks
    $ myConfig


myEventHook = mconcat
    [ dynamicPropertyChange "WM_CLASS" scratchpadManageHook
    , dynamicTitle manageZoomHook
    , handleEventHook def
    ]

myConfig = def { borderWidth        = 2
           , terminal           = myTerminal
           , modMask            = myModMask
           , normalBorderColor  = "#cccccc"
           , focusedBorderColor = "#cd8b00"
           , startupHook        = myStartupHook
           , layoutHook         = myLayout
           , workspaces         = myWorkspaces
           , manageHook         = myManageHook
           , handleEventHook    = myEventHook
           }
           `removeKeysP` myRemoveKeys
           `additionalKeysP` myAdditionalKeys
