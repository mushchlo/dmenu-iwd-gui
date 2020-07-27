# Intro

   This is a little dmenu script I've been working on, and since it's finally usable, I thought I'd share it with the world! What does it do, you ask? It's a dmenu GUI for iwd/iwctl, so it shows you nearby networks, along with their strength and security type, allows you to connect to it with a saved password, and authenticate with a new network, all within dmenu!
   
https://raw.githubusercontent.com/mushchlo/dmenu-iwd-gui/master/dmenu-iwd-gui-1.png
https://raw.githubusercontent.com/mushchlo/dmenu-iwd-gui/master/dmenu-iwd-gui-2.png
https://raw.githubusercontent.com/mushchlo/dmenu-iwd-gui/master/dmenu-iwd-gui-3.png
   
   I figured a suckless\* solution is somewhat missing for a niche such as this, as on a desktop running a standalone WM, you learn to do without things like this, but quite frankly, on a laptop, it gets old having to go into the terminal to scan, get-networks, and connect every time I change location. Hence, this project!

   You'll notice there's quite a bit of very hackish text editing, and my code is messy, so it might not be clear what's going on in every stage, but it's pretty short, and my commenting should hopefully make things clear.

## Requirements
       
   1. A working iwd/iwd+dhcpcd setup
   2. An iwd directory that has read/write (cd) permissions for "other" groups, or an iwd directory in a public location. Default location is /var/lib/iwd, and in my case, I just left it there and made it globally readable and writeable. Maybe not super secure, but quite frankly I'm willing to take whatever slight risk it may pose for convenience's sake. The following commands will do the trick for you (as root): 
        `chmod o=rw /var/lib/iwd && chmod o=rw /var/lib/iwd/*`
   3. I use font-awesome 5 for my wifi symbols for strength, but I've changed the "symbols" to 1 2 and 3, so either use an ASCII string/character or make sure your symbol font is in your dmenu fonts array, as you can't call dmenu with two fonts, so my solution is just to let dmenu handle the fonts on it's own, without any font flag for this script.

## Tips and tricks

   After I connect to a network, in between the `iwctl` bit and `exit` bit, I run a script to reload my dwmblocks wifi block. You can add whatever script you want running after you connect to a network there
                                                                             
## To-Dos                                                                                                                 
   As far as passwords go, through trial and error testing it seems like special characters get preserved as plain text, meaning it connects to the network successfully, even with the special characters, so, *as far as I know*, it works, for now.
<details>                                                                    
        <summary>Nerd shit about the password issue ahead, click if interested. TL;DR: I don't know why something is working and I don't like it.</summary>                                                      
\n
   My implementation of password redirection from the `$pass` variable to `iwctl` is inherently flawed, as it can contain any ASCII character that may be included in a user's WPA2 password (I couldn't find many sources on if unicode characters might also be included), and only goes in double quotes, which theoretically preserves the special treatment of the characters `"`, `\`, `*`, and `$`.
   As said before, it does work, however, because it isn't foolproof, I don't trust it, and I would like to fix it before it poses a problem. Ideally, I would encase the user input in single quotes inside the variable, and then use it without ecaping, as a parameter expansion of `$pass`, but I don't have the BASHism know-how to do that.
   Another solution would be to manually escape the annoying symbols in dmenu, and/or automatically replace the special characters with a backslash followed by the original character, or, better yet, just use `printf`'s `%q` option. However, for some reason, backslashes are actually interpreted as plain text by iwd, which is ridiculously unhelpful. I'd really like help on this if any readers have some spare time, thanks :).
\n
</details>

   I'd like to fix the fact that I'm currently using three text stream editors (awk, sed, and tr) for jobs that I know could be condensed into one editor (probably awk) if I just stop being lazy, but that is an easyish fix if anybody wants to fork the project for it.
   
   Regarding the dmenu font issue, I can't really think of any sort of convenient solution other than using only one font and specifying it in `$dmenu`, or figuring out a way to call dmenu with multiple fonts specified.

If you have a feature request, or a bug report, or an optimization tip, please add an issue! I'm semi-new to using bash for an actual project, so  I really appreciate any and all feedback.
   


\* : not actually suckless, as it isn't written in C, but whatever, its a philosophy, not a set of laws.
