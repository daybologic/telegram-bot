# telegram-bot

[![sourcehut release](Emoji_u1f916.svg)](https://git.sr.ht/~m6kvm/telegram-bot)

Welcome to the Telegram-bot! (@m6kvmdlcmdr) by Rev. Duncan Ross Palmer

## What is Telegram?

[Telegram](https://telegram.org) is a secure messenger used by a diverse audience and used on multiple platforms.
It offers a rich API layer and bots can easily be authorized by having a conversation with a bot called [@BotFather](https://t.me/BotFather).
If you would like to run your own copy of this telegram-bot, you will need to do this!  Start with this [tutorial](https://core.telegram.org/bots/tutorial).

## Documentation

For up to date documentation, please ensure you are viewing the latest copy at [sourcehut](https://git.sr.ht/~m6kvm/telegram-bot/tree/develop/item/README.md)

## Project goals

The project started out as a way to quickly ask a remote copy of [yt-dlp](https://github.com/yt-dlp/yt-dlp) to perform downloads of music videos, but this has thus far been an semi-abandoned goal.  Instead, the bot quickly took on a rapid growth of off-the-cuff ideas. See [Features](#Features).  We would appreciate any patches or forks!

## Setup / installation

TODO: nb. most users will not be installing this bot, and therefore instructions will be perfected later.

For the moment, we will direct you to [Features](#Features) instead.
The bot relies on too many external, unpackaged dependencies at the moment to set up by third parties.

## Talking to the Bot

Find the bot online under the name [m6kvmdlcmdr](https://t.me/m6kvmdlcmdrbot) (@m6kvmdlcmdrbot).
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

All users may remove any meme; we may make this more secure and store your username and allow an admin username, in a later revision of the module.

nb. in future versions, if you do not have a username, use of this command may be restricted.

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

nb. in future versions, your username may be stored along with the meme, for access control reasons, and if you do not have a username, use of this command may be restricted.

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

#### Miscellaneous

##### /me (ignored)

It's common on IRC to say that one is doing something by saying /me.
This bot ignores /me, rather than complaining it doesn't recognize the command.
This allows you to run another bot in the channel which understands and does something with this command.

##### /random

Return a random number.  This is similar to $RANDOM in the shell.
The number is limited to 16-bits in width.  Only one result per execution.

##### /lyfe

Insinuate that somebody is hung over from alcoholic beverages.

TODO: It should be moved into custom commands, defined in a config file

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

##### /ynyr

The old one!  Not as old as all that!
Watch the film 'Krull' before using this comnand.

TODO: It should be moved into custom commands, defined in a config file

##### /horatio

Esoteric: May be removed in a future release.

TODO: It should be moved into custom commands, defined in a config file

##### /ben

Report Ben's live whereabouts
This is a joke command, and it always reports the same thing.
TODO: It should be moved into custom commands, defined in a config file

##### /breakfast

Remind the given user to have their breakfast.
Usage: /breakfast <@username>

##### /lastphoto

Debugging purposes only; returns the staged meme which would be stored with the next /meme add <name> command.
This command is subject to removal, renaming, or potentially a debug-only mode.

#### Undocumented

The following commands are undocumented at the present time.  Please do not use them, until further notice.
All of these are likely to be removed soon.

##### /keyboard

##### /encoding

##### /knock

##### /phone

## Community

- [telegram-bot-discuss (mailing list)](https://lists.sr.ht/~m6kvm/telegram-bot-discuss)

## Contributing

The majority of the code is written in Perl 5
Please join the Community mailing lists and then send patches!

Talk to the bot and run the command /source to see where whence source code may be obtained.
Check which version of the bot you are using before considering running patches.  The easiest way to do this is with the /version command.

We thank thee in advance.

## Security

Please report security issues privately by emailing [2e0eol@gmail.com](mailto:2e0eol@gmail.com).  This is to ensure that anything very serious can be addressed as an emergency before it is announced on the mailing list.

## Credit and contacts

Maintainer - [Rev. Duncan Ross Palmer](mailto:2e0eol@gmail.com)

## License

Code is under a [BSD-style license](COPYING).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
