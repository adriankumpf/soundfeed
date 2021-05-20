# Changelog

## [Unreleased]

## [1.8.0] - 2021-05-20

- Publish Docker image to GH container registry
- Upgrade to Elixir v1.12
- Refactor API module, among others

## [1.7.0] - 2021-02-26

- Remove support for fetching reposts (the SoundCloud API does not allow fetching reposts anymore)
- Update SoundCloud API route to retrieve liked tracks
- Use Tesla with the Finch adapter
- Upgrade to Elixir v1.11
- Migrate to Webpack 5

## [1.6.1] - 2020-08-11

### Bug Fixes

- Fix HTTP pool URLs

## [1.6.0] - 2020-08-11

### Enhancements

- Increase timeouts
- Remove caching layer for user lookups
- Bump phoenix to 1.5
- Use finch as HTTP client
- Refactor JSON decoding
- Include playlist tracks in the reposts feed

### Bug Fixes

- Set charset to UTF-8 in the content-type header
- Return 404 if user was not found

## [1.5.1] - 2019-07-22

### Removed

- Remove unused dependencies

### Changed

- Bump logger_telegram_backend from 1.2.1 to 1.3.0
- Bump lodash from 4.17.11 to 4.17.14

## [1.5.0] - 2019-07-02

### Changed

- Strip umbrella project down
- Replace distillery with Elixir (v1.9) releases

## [1.4.3] - 2019-03-28

### Changed

- Disallow special chars in user names

### Fixed

- Update tzdata: tz release 2019a caused errors due to a typo in tz data

## [1.4.2] - 2019-03-17

### Fixed

- Increase http timeout

## [1.4.1] - 2019-03-16

### Changed

- Update FAQ

### Fixed

- Use integer as retry value

## [1.4.0] - 2019-03-15

### Changed

- Streamline project structure
- Refactor and modernize SoundFeed
- Log less retry messages
- Update dependencies

### Removed

- Remove type specs and dialyzer

### Fixed

- Send client_id with every pagination request

## [1.3.2] - 2018-03-25

### Changed

- Update dependencies

## [1.3.1] - 2018-01-18

### Changed

- Update LoggerTelegramBackend to v1.0
- Use the DynamicSupervisor

## [1.3.0] - 2018-01-04

### Added

- Add TelegramLoggerBackend in production
- Send weekly reports

## [1.2.2] - 2017-10-12

### Changed

- Load client_id from environment variable in prod

### Fixed

- Run release as non-root
- Don't gzip feeds

## [1.2.1] - 2017-09-17

### Added

- Deploy release in a minimal docker container

## [1.2.0] - 2017-08-13

### Added

- Add type specs
- Use credo

### Fixed

- Load cookie value from environment variable

## [1.1.0] - 2017-08-12

### Added

- Use Elixir's new child specs
- Add deploy scripts
- Set secrets via environment variables

## [1.0.0] - 2017-08-12

[unreleased]: https://github.com/adriankumpf/soundfeed/compare/v1.8.0...HEAD
[1.8.0]: https://github.com/adriankumpf/soundfeed/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/adriankumpf/soundfeed/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/adriankumpf/soundfeed/compare/v1.5.1...v1.6.0
[1.5.1]: https://github.com/adriankumpf/soundfeed/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/adriankumpf/soundfeed/compare/v1.4.3...v1.5.0
[1.4.3]: https://github.com/adriankumpf/soundfeed/compare/v1.4.2...v1.4.3
[1.4.2]: https://github.com/adriankumpf/soundfeed/compare/v1.4.1...v1.4.2
[1.4.1]: https://github.com/adriankumpf/soundfeed/compare/v1.4.0...v1.4.1
[1.4.1]: https://github.com/adriankumpf/soundfeed/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/adriankumpf/soundfeed/compare/v1.3.2...v1.4.0
[1.3.2]: https://github.com/adriankumpf/soundfeed/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/adriankumpf/soundfeed/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/adriankumpf/soundfeed/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/adriankumpf/soundfeed/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/adriankumpf/soundfeed/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/adriankumpf/soundfeed/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/adriankumpf/soundfeed/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/adriankumpf/soundfeed/compare/6892f68...v1.0.0
