# telegram-bot

[![sourcehut release](Emoji_u1f916.svg)](https://git.sr.ht/~m6kvm/telegram-bot)

Welcome to the Telegram-bot! (@m6kvmbot) by Rev. Duncan Ross Palmer

## What is Telegram?

[Telegram](https://telegram.org) is a secure messenger used by a diverse audience and used on multiple platforms.
It offers a rich API layer and bots can easily be authorized by having a conversation with a bot called [@BotFather](https://t.me/BotFather).

## Documentation

For up to date documentation, please ensure you are viewing the latest copy at [sourcehut](https://git.sr.ht/~m6kvm/telegram-bot/tree/master/item/README.md)

## Project goals

The project started out as a way to quickly ask a remote copy of [yt-dlp](https://github.com/yt-dlp/yt-dlp) to perform downloads of music videos, but this has thus far been an semi-abandoned goal.  Instead, the bot quickly took on a rapid growth of off-the-cuff ideas. See [Features](#Features).  We would appreciate any patches or forks!

## Setup / installation

Note that most users can talk to the bot directly, using Telegram
I direct you to [Features](#Features) instead, or [Talking to the Bot](#Talking to the Bot).

As the bot relies on many external, unpackaged dependencies at the time of writing, it is highly recommended that you use
the [Git](https://git-scm.com) SCM in order to fetch everything necessary.  Potentially, in the future, we might support [Docker](https://www.docker.com)

Firstly, obtain the Git SCM.  Setting Git up is outside the scope of this documentation.  Once this is installed, fetch the latest
version of the project using:

git clone --recursive git@git.sr.ht:~m6kvm/telegram-bot
cd telegram-bot/
cp debian/etc/\*.conf etc/debian/

mkdir ~/.aws
cp debian/etc/config debian/etc/credentials ~/.aws/

Now modify etc/debian/telegram-bot.conf and add keys as necessary from the various upstream vendors,
and change personal preferences.

Create a bucket with read/write privileges at S3 for meme features.  The bucket key must be set in the config,
and the credentials must be set in the ~/.aws/ config under the profile 'telegram'.
You also need a DynamoDB table called 'excuses4' if you want to use the /error feature.  nb. this feature is not really production ready, so any patches are appreciated.

Talk to the [@BotFather](https://t.me/BotFather).  Start with this [tutorial](https://core.telegram.org/bots/tutorial).
Ensure the token it in the config, or the bot will not start.

Run bin/install.sh

This will create required cache directories.
Then run

sudo chown $USER /var/cache/telegram-bot

### Database

Set up a [MariaDB](https://mariadb.org) database, and pipe the following credentials and schema in using:

mariadb -u root -h HOST < schema.sql
mariadb -u root -h HOST telegram_bot < grants.sql
mariadb -u root -h HOST telegram_bot < data.sql

Note that grants.sql contains a false password, which you will need to reset to a known value, and copy into etc/telegram-bot.conf

Finally, start a screen session using SCREEN(1),
and run:

bin/run-bot.sh

## Talking to the Bot

Find the bot online under the name [m6kvmbot](https://t.me/m6kvmbot) (@m6kvmbot).
The exact username is due to a requirement by Telegram for all bots' usernames to end with the word 'bot'.

If you run the bot yourself, substitute your preferred username - but remember that aforementioned requirement.

### Features

#### 8ball

the /8ball command looks into a crystal ball and tells you whether or not you should do something.
It is always right!

Disclaimer: Don't ask for serious advice, we don't condone self-harm.  The bot is not a financial advisor, nor a lawyer, nor a doctor.  In fact, it doesn't really have any qualifications at all.

Usage: /8ball question

#### HTTP.cat

The HTTP /cat command, returns an image representing an [HTTP error code](https://http.dev/status).

The images are shamelessly taken from the [http.cat](https://http.cat/) whimsical website.

usage: /cat code

#### Currency conversion

##### /usd

Convert a currency amount in GBP to USD.  Usage: /usd <123.45>

##### /gbp

Convert a currency amount in USD to GBP.  Usage: /gbp <123.45>

#### Drinks/snacks counters

In order to keep a count of how many drinks you are having in a day, you may use the following counters, none of which take an argument:

All of these counters are analogous:

##### /beer (or /🍺)

##### /coffee (or /☕️)

##### /tea (or /🫖)

##### /water (or /💦)

This uses your username and the data is expired if not used for eight hours, which means you can start again the next day without any kind of manual reset.

#### Environmental information

##### /restart

If you are an administrator, type /restart and the bot will restart.

##### /source

For the latest information on how to obtain the source code, type:
/source

##### /start

This command does not start the bot, it is used to list all of the supported commands.
This is standard Telegram parlance.

##### /stop

If you are an administrator, type /stop and the bot will exit.
In order to restart the bot, an adminstrator will need to run the script again.
This may be a useful feature if the bot is being abused and the relevant parties can't be specifically identified at the present time.

##### /uptime

For how long the machine the bot is running on has been up, and how long the script has been running, without a fatal error occurring or a restart by an administrator, type:
/uptime

##### /version

To obtain version information from the running bot, and potentially other modules, type:
/version

#### Emojis

Emojis are easily acceessible on most modern platforms but not all, you can instruct the bot to use some pre-determined emojis and series of emojis for various in-jokes, as follows:

##### /bitbucket

The website [bitbucket.org](https://bitbucket.org):
0️⃣1️⃣🪣'

##### /disapproval

The Look of [disapproval](https://looks.wtf):

ಠ_ಠ

##### /shrug

The "shruggie", which was in common use before 🤷‍♀️

¯\_(ツ)_/¯

##### /tableflip

Produces the following image:
(┛ಠ_ಠ)┛彡┻━┻

##### /bird

A bird:
🕊️

We often use this to indicate that code is OK.

##### /sis

Ship-it Squrrel:
🚢🐿️

We often use this to indicate that code is OK.

#### Errors

You may solicit a random and stupid error or technical excuse by using /error
This command takes no parameters.  A future enhancement may allow a repeatable error based on an integer,
but it is undecided how to implement this.  Perhaps if an ID is reported within the error.

#### Gender

Some commands may refer to you as 'they' or 'their' because the bot does not known your gender.  If you would like to set
a gender, type one of:

/gender female

or

/gender male

You cannot use this command if you have not configured a username within Telegram.

In order to see your current gender, type /gender

It is not currently possible to remove your selected gender and revert to 'they'.

#### Kappagen

Type /kappagen for some random emojis
This is based on the Twitch !kappagen feature.
You may be specify the emojis to generate too, and the number of output characters, up to a limit.

Example:

/kappagen 🪯🚕📌😶🤤 500

#### Karma

Karma is a way of storing scores against arbitary terms.  It is does in increments (you like something) or decrements,
where you dislike something and want to reduce the score.  Nobody really gets any prizes out of this.

To increase karma, replace term with any word:

/k term++

To decrease karma:

/k term--

This is in stored in a MariaDB backend.

Reports aren't yet available, but you are given immediate feedback.

#### Memes

Dynamic meme handling is one of the core features of the bot; we allow meme use, addition, removal, and search.

##### Search

In order see a list of memes, type /m critereon.  If your meme matches meme exactly, it is used - try to make
your meme search query less precise.  A good starting point might be, for example:

/m e

which would list all memes containing the letter 'e', up until the maximum meme list size, which is limited by Telegram,
and not by the bot code, at present.  You can narrow down the search as required.

##### Removal

If a meme is useless, incorrect, or offensive, you may remove the meme by using:

/meme rm name

The name must be exact.

Synonyms: 'remove', 'delete', 'del', 'erase', 'expunge', 'purge'

If you added the meme, you are permitted to remove it, otherwise you must be an admin to remove a meme.

You must have a Telegram username (Telegram makes this optional), in order to use this command.

##### Use

To use a meme, the following syntaxes are supported:

/m name

/m #name

/name

ie. any unknown command will map to a meme.
Note that if another command conflicts with the name of the meme, in the /name syntax, the command will take precedence, and the meme is inaccesible using that syntax; this is for obvious security reasons, or vital commands might become unusable.

##### Adding

Message the bot privately and send JPEG image.  Please don't try other image types, it is unsupported.

Once the bot acknowledges that it has seen your meme (it will say so),
type /meme add name.

If the meme name is already used, this operation will fail.  If this happens, pick another name.  You do not have to send the picture again.

Synonyms: 'new'

Note that all memes are accessible to all users, so please be considerate.  If you are hosting the code yourself, the memes are under your control, but others can access them.

You must have a Telegram username (Telegram makes this optional), in order to use this command.  Your username will be stored alongside the meme, but it will not be exposed to other users.  This is purely to facilitate you removing or replacing the meme, without the need for intervention by an administrator.

#### Music

Commands related to music

##### /search

Search through the author's collection;

Note that this method is presently broken, for unknown reasons, and will be restored as soon as possible.
In the future, we will allow downloading this music via the bot too.

#### UUIDs

Relating to [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)s;
These services are all handled by a backend microservice.

##### Generating a UUID

In its simplest form, in order to obtain a unique identifier,
Usage: /uuid

The default version of UUID is 1.  In order to obtain a version 4 UUID, specify /uuid v4.
If you need multiple UUIDs. specify an integer.  For example, to obtain five UUIDs, using the version 4 scheme:

/uuid v4 5

or

/uuid 5 v4

Order of arguments is not important here.

#### Obtaining UUID information

TODO: /uuid uuid doesn't work
In theory it gives information about UUIDs, but it's broken.  We're sorry

#### Weather

In order to obtain the weather for any location use /weather location
A report of the weather for the specified location at the present time is returned.
The location should be a city, or identifiable place.  The format of the report may change between releases.

If you have set a username, the bot will remember you and the location you looked up last, allowing you to use /weather
without a location in the future.

The backend used for /weather uses [visualcrossing.com](https://www.visualcrossing.com) with their permission,
and the Perl library [Geo::Weather::VisualCrossing](https://git.sr.ht/~m6kvm/libgeo-weather-visualcrossing-perl)

You will need this library and an API token from Visual Crossing in order to use this feature, if you plan to use the bot yourself, or develop the feature.

#### XKCD

The website [XKCD](https://xkcd.com) produces a regular comic, and each one is numbered.
If you know the number of the comic, usage:

/xkcd nnnn

#### Miscellaneous

##### /me (ignored)

It's common on IRC to say that one is doing something by saying /me.
This bot ignores /me, rather than complaining it doesn't recognize the command.
This allows you to run another bot in the channel which understands and does something with this command.

##### /random

Return a random number.  This is similar to $RANDOM in the shell.
The number is limited to 16-bits in width.  Only one result per execution.

##### /insult

Produce a random insult
WARNING: May not be politically correct; may cause offence!

##### /miles

Convert a number of kilometers into miles.

Usage: /miles km

km must be a number.

##### /say

The bot will repeat whatever you write here.  This is mostly so you can start other text beginning with '/', without producing an error.

/say <text>

##### /yt

This command is used to remotely download from YouTube but it doesn't work!
In a future release, the bot will download something on your behalf and then produce a link.

##### /breakfast

Remind the given user to have their breakfast.
Usage: /breakfast <@username>

##### /lastphoto

Debugging purposes only; returns the staged meme which would be stored with the next /meme add <name> command.
This command is subject to removal, renaming, or potentially a debug-only mode.

##### /units

Works as a calculator, an English phrase, such as "a pint of Guinness" returns the number of units in that drink.
If only a number is specified, this is considered the number of units, and the calculation is not performed.

###### /units record

If you use /units record, the last number of units looked up will be recorded in the database with your username, and the present time.

###### /units report

Generate a report for your drinking

###### /units undo

Remove the previous drink recorded against your name from the database

###### /units last

The time when you last had an alcoholic drink

## Community

- [telegram-bot-discuss (mailing list)](https://lists.sr.ht/~m6kvm/telegram-bot-discuss)

## Contributing

The majority of the code is written in Perl 5
Please join the Community mailing lists and then send patches!

Talk to the bot and run the command /source to see where whence source code may be obtained.
Check which version of the bot you are using before considering running patches.  The easiest way to do this is with the /version command, or look for $VERSION in lib/Telegram/Bot.pm

We thank thee in advance.

## Security

Please report security issues privately by emailing [2e0eol@gmail.com](mailto:2e0eol@gmail.com).  This is to ensure that anything very serious can be addressed as an emergency before it is announced on the mailing list.

## Credit and contacts

Maintainer - [Rev. Duncan Ross Palmer](mailto:2e0eol@gmail.com)

## License

Code is under a [BSD-style license](COPYING).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
