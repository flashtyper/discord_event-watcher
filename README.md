# discord_event-watcher
checks if someone created or changed a discord event and warns if the event starts in 1 hour:


![grafik](https://user-images.githubusercontent.com/83031404/156826235-234aecb7-5b55-420a-bf3d-367fdaeb728c.png)
![grafik](https://user-images.githubusercontent.com/83031404/156826886-7381b237-e877-47bf-af53-d2f1f6de3217.png)
![grafik](https://user-images.githubusercontent.com/83031404/156827129-1376662d-bd40-47c0-8622-debc20207d64.png)

# Installation
**required:** 
- discord.js https://discord.js.org/
- gateway intents: GUILDS, GUILD_EVENTS, GUILD_MESSAGES
- this index.js :)

# Configuration
You need:
- a BOT-Token
- a channel-id in which the bot send the messages
- a guild id (obvious)
- a role-id (needs the bot for the 1h-reminder)
Please configure these four things first before running.

# Start the Bot
I recommend to use a screen instance (works great for me). So install "screen" with apt install screen and create a new screen instance with `screen`. After that, execute this index.js with `node index.js`. 

After that, exit the screen instance with `STRG + A, D`. For further information see https://wiki.ubuntuusers.de/Screen/

# Misc
open an issue if anything weird happens or if you would like to have an improvement. thx
