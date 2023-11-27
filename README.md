# Steam Age Checker for FiveM Server

This resource is designed to prevent spoofers and trolling by checking the age of Steam accounts attempting to join your FiveM server.

## Configurations

### Steam API Key

Before using this resource, make sure to obtain your Steam API key from [Steam Community Developer](https://steamcommunity.com/dev). Replace "YOUR_API_KEY" in the configuration with your actual API key.

```local apiKey = "YOUR_API_KEY" -- Steam API key https://steamcommunity.com/dev```

### Days Threshold

Adjust the `daysThreshold` variable to set the minimum age (in days) required for a Steam account to join your server.


```local daysThreshold = 15 -- Days old to check```

### Private profile check: 
If the player has a private profile, allow them to join (true)
If you want to block the connection, set it to false
```callback(true) -- Change this```

### My Spanish Roleplay Server / Mi Servidor de Roleplay 🆑

[![Server Image](https://i.imgur.com/RBeTFIC.png)](https://discord.gg/loudrp)

### My discord: martinnn8911


