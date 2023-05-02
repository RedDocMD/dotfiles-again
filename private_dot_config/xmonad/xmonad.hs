import           Control.Monad               (forM_, join, mapM)
import           Data.List                   (intercalate, sortBy)
import           Data.Function               (on)
import           Data.Functor                ((<&>))
import           System.Directory
import           System.Exit
import           System.FilePath
import           System.Random
import           System.Random.Stateful
import           XMonad
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.DynamicProperty
import           XMonad.Hooks.EwmhDesktops   (ewmh, ewmhFullscreen)
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers  (isDialog, doSink)
import           XMonad.Hooks.StatusBar
import           XMonad.Hooks.StatusBar.PP
import           XMonad.Layout.Gaps
import           XMonad.Layout.Spacing       (spacing)
import qualified XMonad.StackSet             as W
import           XMonad.Util.EZConfig        (additionalKeysP, removeKeysP)
import           XMonad.Util.Loggers
import           XMonad.Util.NamedScratchpad
import           XMonad.Util.NamedWindows    (getName)
import           XMonad.Util.Run             (safeSpawn)
import           XMonad.Util.SpawnOnce       (spawnOnce)

myModMask = mod4Mask  -- Rebind Mod to Super Key
myTerminal = "alacritty"

rofiCmd = "rofi -show drun -font \"Iosevka Term 12\" -icon-theme \"Papirus\" -show-icons"
        ++ " -theme \"dracula\""

scrotCmd = "sleep 0.2; scrot -s -F ~/Pictures/%Y-%m-%d-%T-screenshot.png"

myAdditionalKeys = [ ("M-p", spawn rofiCmd)
                   , ("M-a", spawn "alacritty -e ranger")
                   , ("M-M1-q", io (exitWith ExitSuccess))
                   , ("<XF86AudioRaiseVolume>", spawn "amixer -q -D pulse sset Master 5%+")
                   , ("<XF86AudioLowerVolume>", spawn "amixer -q -D pulse sset Master 5%-")
                   , ("<XF86AudioMute>", spawn "amixer -D pulse set Master 1+ toggle")
                   , ("<XF86AudioPlay>", spawn "playerctl play-pause")
                   , ("<XF86AudioNext>", spawn "playerctl next")
                   , ("<XF86AudioPrev>", spawn "playerctl previous")
                   , ("<Print>", spawn scrotCmd)
                   , ("M-C-s", namedScratchpadAction myScratchpads "spotify")
                   , ("M-C-t", namedScratchpadAction myScratchpads "term")
                   , ("M1-C-f", sendMessage $ JumpToLayout "Full")
                   , ("M1-C-t", sendMessage $ JumpToLayout "Tall")
                   , ("M1-C-l", spawn "slock")
                   , ("M-b", sendMessage ToggleStruts)
                   , ("M-C-r", setRandomWallpaper)
                   ] ++
                   [ (otherModMasks ++ "M-" ++ [key], action tag)
                     | (tag, key) <- zip myWorkspaces "1234567890"
                     , (otherModMasks, action) <- [ ("", windows . W.greedyView),
                                                    ("S-", windows . W.shift) ]
                   ]

myRemoveKeys = [ "M-S-q" ]

myLayout = avoidStruts . gaps [(D, 12)] . spacing 7 $ tiled ||| Mirror tiled ||| Full
    where
        tiled = Tall nmaster delta ratio
        nmaster = 1
        ratio   = 1/2
        delta   = 3/100

wallpapersDirs :: [FilePath]
wallpapersDirs = ["/usr/share/backgrounds/nordic-wallpapers/"]

isImageFile :: FilePath -> Bool
isImageFile name = extension name `elem` [".jpg", ".jpeg", ".png"]
    where
        extension = dropWhile (/= '.')

dirFiles :: FilePath -> IO [FilePath]
dirFiles dir =
    getDirectoryContents dir
        >>= mapM (canonicalizePath . (dir </>))
        .   filter isImageFile

wallpaperPaths :: IO [FilePath]
wallpaperPaths = mapM dirFiles wallpapersDirs <&> concat

randomWallpaper :: IO FilePath
randomWallpaper = do
    paths <- wallpaperPaths
    rand <- uniformM globalStdGen
    let idx = abs rand `mod` length paths
    return $ paths !! idx

getRandomWallpaperCmd :: IO String
getRandomWallpaperCmd = do
    wallpaper1 <- randomWallpaper
    wallpaper2 <- randomWallpaper
    return $ intercalate " " ["feh", "--no-fehbg", "--bg-fill", wallpaper1, wallpaper2]

setRandomWallpaper :: X ()
setRandomWallpaper = do
    cmd <- io getRandomWallpaperCmd
    spawn cmd

myStartupHook = do
     spawnOnce "picom"
     spawnOnce "wmname LG3D"
     spawnOnce "dunst"
     spawnOnce "dropbox"
     spawnOnce "nm-applet"
     spawnOnce "xsetroot -cursor_name left_ptr"
     spawn "killall stalonetray"
     spawn "sleep 1; stalonetray"
     setRandomWallpaper


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
      -- , className =? "Chromium"          --> doShift (myWorkspaces !! 1)
      -- , stringProperty "WM_NAME" =? "Firefox Developer Edition" --> doShift (myWorkspaces !! 1)
      , stringProperty "WM_NAME" =? "Picture-in-Picture" --> doFloat
      , className =? "JetBrains Toolbox" --> doFloat
      , className =? "Bitwarden"         --> doFloat
      , className =? "Animated Cartoon"  --> doFloat
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
           , normalBorderColor  = "#282828"
           , focusedBorderColor = "#8ec07c"
           , startupHook        = myStartupHook
           , layoutHook         = myLayout
           , workspaces         = myWorkspaces
           , manageHook         = myManageHook
           , handleEventHook    = myEventHook
           }
           `removeKeysP` myRemoveKeys
           `additionalKeysP` myAdditionalKeys
