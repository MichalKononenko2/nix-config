import XMonad (xmonad, terminal, modMask, mod4Mask, X, startupHook, layoutHook)
import XMonad.Config.Xfce (xfceConfig)
import XMonad.Util.Run (safeSpawn)
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Layout ((|||), Tall(..), Mirror(..), Full(..), Choose)

main :: IO ()
main = xmonad $ xfceConfig {
  terminal = "xfce4-terminal --hide-menubar --hide-scrollbar",
  modMask = mod4Mask,
  layoutHook = myLayout,
  startupHook = myStartupHook
}

myStartupHook :: X ()
myStartupHook = safeSpawn "feh" ["--bg-fill", myWallpaper]

myLayout :: Choose Tall Full a
myLayout = tiled ||| Full
  where
    tiled = Tall numberOfMasterWindows resizingPercentIncrement defaultRatio
    numberOfMasterWindows = 1
    defaultRatio = 1/2
    resizingPercentIncrement = 3/100

-- This gets defined in configuration.nix 
myWallpaper :: String

