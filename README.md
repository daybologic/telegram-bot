# telegram-bot

[![sourcehut release](https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/circles1.svg)](https://git.sr.ht/~m6kvm/telegram-bot)

Welcome to the Telegram-bot! (@m6kvmdlcmdr) by Rev. Duncan Ross Palmer

## What is Telegram?

[Telegram](https://telegram.org) is a secure messenger used by a diverse audience and used on multiple platforms.
It offers a rich API layer and bots can easily be authorized by having a conversation with a bot called [@BotFather](https://t.me/BotFather).
If you would like to run your own copy of this telegram-bot, you will need to do this!  Start with this [tutorial](https://core.telegram.org/bots/tutorial).

## Documentation

For up to date documentation, please ensure you are viewing the latest copy at [sourcehut](https://git.sr.ht/~m6kvm/telegram-bot/tree/f/docs/item/README.md)

## Project goals

The project started out as a way to quickly ask a remote copy of [yt-dlp](https://github.com/yt-dlp/yt-dlp) to perform downloads of music videos, but this has thus far been an semi-abandoned goal.  Instead, the bot quickly took on a rapid growth of off-the-cuff ideas. See features.  We would appreciate any patches or forks!

## Setup / installation

TODO: nb. most users will not be installing this bot, and therefore instructions will be perfected later.
For the moment, we will direct you to features instead.

The bot relies on too many external, unpackaged dependencies at the moment to set up by third parties.

## Talking to the Bot

Find the bot online under the name [m6kvmdlcmdr](https://t.me/m6kvmdlcmdrbot) (@m6kvmdlcmdrbot).
The exact username is due to a requirement by Telegram for all bots' usernames to end with the word 'bot'.

If you run the bot yourself, substitute your preferred username - but remember that aforementioned requirement.

### Features

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

TODO

#### UUID generation

In its simplest form, in order to obtain a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) type /uuid

TODO: /uuid <uuid> doesn't work

#### Weather

In order to obtain the weather for any location use /weather <location>
A report of the weather for the specified location at the present time is returned.
The location should be a city, or identifiable place.  The format of the report may change between releases.

If you have set a username, the bot will remember you and the location you looked up last, allowing you to use /weather
without a location in the future.

The backend used for /weather uses [visualcrossing.com](https://www.visualcrossing.com) with their permission,
and the Perl library [Geo::Weather::VisualCrossing](https://git.sr.ht/~m6kvm/libgeo-weather-visualcrossing-perl)

You will need this library and an API token from Visual Crossing in order to use this feature, if you plan to use the bot yourself, or develop the feature.

## Community

- [telegram-bot-discuss (mailing list)](https://lists.sr.ht/~m6kvm/telegram-bot-discuss)

## Contributing

Please join the Community mailing lists and then send patches!

We thank thee in advance.

## Security

Please report security issues privately by emailing [2e0eol@gmail.com](mailto:2e0eol@gmail.com).  This is to ensure that anything very serious can be addressed as an emergency before it is announced on the mailing list.

## Credit and contacts

Maintainer - [Rev. Duncan Ross Palmer](mailto:2e0eol@gmail.com)

## License

Code is under a [BSD-style license](COPYING).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).
