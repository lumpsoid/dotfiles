import XMonad

import XMonad.Util.EZConfig
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Magnifier
import XMonad.Hooks.EwmhDesktops

import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Util.Loggers

import XMonad.Hooks.ManageDocks

import XMonad.Actions.Promote

import XMonad.Layout.MultiToggle as MultiToggle
import XMonad.Layout.MultiToggle.Instances (StdTransformers(FULL))

myLayout = mkToggle (single FULL) $ (tiled ||| Mirror tiled ||| Full ||| threeCol)
  where
    threeCol = magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    tiled    = Tall nmaster delta ratio
    nmaster  = 1      
    ratio    = 1/2    
    delta    = 3/100

main :: IO ()
main = xmonad
     . docks
     . ewmhFullscreen
     . ewmh
     -- . withEasySB (statusBarProp "xmobar ~/.config/xmobar/xmobarrc" (pure myXmobarPP)) defToggleStrutsKey
     $ myConfig

myConfig = def
    { modMask = mod4Mask  -- Rebind Mod to the Super key
    , layoutHook = avoidStruts $ myLayout  -- Use custom layouts
    }
    `additionalKeysP`
    [ ("M-w"  ,        spawn "brave"                             )
    , ("M-<Return>",   spawn "kitty --single-instance"           )
    , ("M-d"  ,        spawn "dmenu_run"                         )
    , ("M-c"  ,        kill                                      )
    , ("M-<Space>"  ,  promote                                   )
    , ("M-u"  ,        sendMessage NextLayout                    )
    , ("M-f",          sendMessage $ MultiToggle.Toggle FULL                 )
    , ("<Print>", spawn "sc-printscreen")
    , ("<XF86AudioRaiseVolume>", spawn "l--volume-control change 2%+")
    , ("<XF86AudioLowerVolume>", spawn "l--volume-control change 2%-")
    , ("<XF86AudioMute>",        spawn "l--volume-control toggle")

    , ("<XF86MonBrightnessUp>",        spawn "brightnessctl s +2%")
    , ("<XF86MonBrightnessDown>",        spawn "brightnessctl s 2%-")
    ]

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppHidden          = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap (white    "[") (white    "]") . magenta . ppWindow
    formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue    . ppWindow

    -- | Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""
