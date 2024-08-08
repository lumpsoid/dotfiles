import XMonad

import XMonad.Util.EZConfig -- basic config
import XMonad.Layout.ThreeColumns -- layout
import XMonad.Layout.Magnifier -- layout
import XMonad.Hooks.EwmhDesktops -- fullscreenEventHook
-- xmobar
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.ManageHook -- manageDocks


main :: IO ()
main = xmonad 
      . ewmhFullscreen 
      . ewmh 
      . xmobarProp
      . withEasySB (statusBarProp "xmobar" (pure xmobarPP)) defToggleStrutsKey -- defToggleStrutsKey = M-b
      $ myConfig

myConfig = def
    { modMask = mod4Mask  -- Rebind Mod to the Super key
    , layoutHook = myLayout  -- Use custom layouts
    , manageHook = myManageHook
    }  
  `additionalKeysP`
    [ ("M-f"  , spawn "librewolf"),                   ),
    ("M-Enter", spawn "st"),
    ("M-d", spawn "rofi -show run"),
    ]
myLayout = tiled ||| Mirror tiled ||| Full ||| threeCol
  where
    threeCol = magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    tiled   = Tall nmaster delta ratio
    nmaster = 1      -- Default number of windows in the master pane
    ratio   = 1/2    -- Default proportion of screen occupied by master pane
    delta   = 3/100  -- Percent of screen to increment by when resizing panes

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    , isDialog            --> doFloat
    ]

