const { Client, Intents, Discord, MessageEmbed } = require("discord.js");
const client = new Client({intents: [Intents.FLAGS.GUILDS, Intents.FLAGS.GUILD_SCHEDULED_EVENTS, Intents.FLAGS.GUILD_MESSAGES]});


//const BOT_TOKEN = 'OTQ0OTU3OTMwMTExOTE0MDQ0.YhJKpw.xOXmcMsYnW_jikPsKj7DZTvGakc'; //dev-bot 1
const BOT_TOKEN = 'NzgzOTQ5NDk4MjE3MDA1MTE3.X8iL3Q.dW0L-KhrxI7cPQM8FFhneSgyXx0'; // event kontr OI llierer
client.login(BOT_TOKEN);

//const guildID = "944957512678002749"; //dev-srv
//const channelID = "944957512678002753"; // write

const guildID = "184368017080057856"; // oi-discord
const channelID = "711281978707673178"; // derhartekern
const groupID = "390604433211260929"; //Admin

var txtChannel;



client.on("guildScheduledEventCreate", guildEvent => {
        txtChannel.send(
                "<@"
                + guildEvent.creatorId
                + "> hat ein neues Event erstellt!\n"
                + "https://discord.com/events/" + guildEvent.guildId + "/" + guildEvent.id
        );

});
client.on("guildScheduledEventUpdate", (Old, New) => {
        //console.log(Old);
        //console.log(New);

        if (Old.name !== New.name && Old.scheduledStartTimestamp === New.scheduledStartTimestamp) {
                // only name change
                txtChannel.send(
                        "Der Name des Events **" + Old.name + "** wurde geaendert!\n"
                        + "**Alt:** " + Old.name + "\n"
                        + "**Neu:** " + New.name + "\n"
                        + "https://discord.com/events/" + guildID + "/" + New.id
                );
        } else if (Old.name === New.name && Old.scheduledStartTimestamp !== New.scheduledStartTimestamp) {
                // only timechange
                txtChannel.send(
                        "Der Start des Events **" + New.name + "** wurde geaendert!\n"
                        + "**Alt:** " + convTime(Old.scheduledStartTimestamp) + "\n"
                        + "**Neu:** " + convTime(New.scheduledStartTimestamp) + "\n"
                        + "https://discord.com/events/" + guildID + "/" + New.id
                );
        } else if (Old.name !== New.name && Old.scheduledStartTimestamp !== New.scheduledStartTimestamp) {
                // name and time changed
                txtChannel.send(
                        "Das Event **" + Old.name + " **wurde geaendert!\n"
                        + "**Alter Name:** " + Old.name + " // " + "**Neuer Name:** " + New.name + "\n"
                        + "**Alter Start:** " + convTime(Old.scheduledStartTimestamp) + " // "
                        + "**Neuer Start:** " + convTime(New.scheduledStartTimestamp) + "\n"
                        + "https://discord.com/events/" + guildID + "/" + New.id
                );
        }
});

function convTime(UNIX_timestamp){
        var date = new Date(UNIX_timestamp);
        var string = date.toLocaleString('de-DE', {timeZone: 'Europe/Berlin'});
        return string;
}

function check1H(UNIX_timestamp){
        var date = new Date(UNIX_timestamp);
        var now = new Date();

        if (date.getDate() === now.getDate() && date.getMonth() === now.getMonth() && date.getYear() === now.getYear() && date.getHours()-1 === now.getHours() && date.getMinutes() === now.getMinutes()) {
                return true;
        }

        return false;
}

function checkEvents(events) {
        events = client.guilds.cache.get(guildID).scheduledEvents.cache;

        events.forEach(function(key, val) {
                if (check1H(key.scheduledStartTimestamp)) {
                        txtChannel.send(
                                "<@&" + groupID + "> Das Event **" + key.name + "** startet in einer Stunde!\n"
                                + "https://discord.com/events/" + guildID + "/" + key.id
                        );
                }
        });
        setTimeout(function () {
                checkEvents(events);
        }, 60000);
}




client.on("ready", () => {
        txtChannel = client.guilds.cache.get(guildID).channels.cache.get(channelID);
        checkEvents(client.guilds.cache.get(guildID).scheduledEvents.cache);
});
